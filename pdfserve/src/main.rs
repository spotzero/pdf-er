#![feature(proc_macro_hygiene)]
#![feature(decl_macro)]

#[macro_use]
extern crate rocket;

use rocket::http::ContentType;
use rocket::http::Status;
use rocket::request::Form;
use rocket::response::status;
use rocket::response::Response;
use rocket::State;
use std::fs;
use std::io::Cursor;
use std::process::Command;
use std::sync::Mutex;
use uuid::Uuid;
use validator;

struct AvailableScreens {
    screens: Mutex<Vec<bool>>,
}

#[derive(FromForm)]
struct RemoteURL {
    url: String,
}

#[get("/?<remoteurl..>")]
fn getpdf(
    remoteurl: Option<Form<RemoteURL>>,
    screens: State<AvailableScreens>,
) -> Result<Response<'static>, status::Custom<String>> {
    if let Some(remoteurl) = remoteurl {
        let screen = get_screen(&screens);
        if let Err(e) = screen {
            return Err(status::Custom(Status::TooManyRequests, e.to_string()));
        }
        let screen = screen.unwrap();

        if validator::validate_url(&remoteurl.url) {
            let name = Uuid::new_v4().to_string();
            let pdf_path = format!("/output/{}.pdf", name);
            println!("Generating PDF for {} with profile {}", remoteurl.url, name);
            let pdf_status = Command::new("/app/bin/generate-pdf.sh")
                //.env("DEV", "1")
                .env("URL", &remoteurl.url)
                .env("PDFNAME", &name)
                .status();

            if let Err(e) = pdf_status {
                shutdown(name, screen, &screens);
                return Err(status::Custom(Status::ServiceUnavailable, e.to_string()));
            }

            let pdf_file = fs::read(pdf_path);
            if let Err(e) = pdf_file {
                shutdown(name, screen, &screens);
                return Err(status::Custom(Status::ServiceUnavailable, e.to_string()));
            }

            let pdf_file = pdf_file.unwrap();

            let response = Response::build()
                .status(Status::Ok)
                .header(ContentType::PDF)
                .sized_body(Cursor::new(pdf_file))
                .finalize();
            shutdown(name, screen, &screens);
            Ok(response)
        } else {
            release_screen(screen, &screens);
            Err(status::Custom(
                Status::NotAcceptable,
                "URL doesn't appear to be valid.".into(),
            ))
        }
    } else {
        Err(status::Custom(
            Status::NotAcceptable,
            "You must specify a URL in the GET parameter to use this service (add: ?url=<URI>)"
                .into(),
        ))
    }
}

#[get("/status")]
fn status() -> String {
    "Ok".into()
}

fn shutdown(name: String, screen: usize, screens: &AvailableScreens) {
    let _ = fs::remove_file(format!("/output/{}.pdf", name));
    release_screen(screen, &screens);
}

fn get_screen(screens: &AvailableScreens) -> Result<usize, String> {
    let mut lock = screens.screens.lock().expect("lock shared data");
    let mut screen = 0;
    let mut no_screens = true;

    for (screen_id, used) in lock.iter().enumerate() {
        if !used {
            screen = screen_id;
            no_screens = false;
        }
    }

    if no_screens {
        Err("No screens currently available, try again later.".to_string())
    } else {
        lock[screen] = true;
        Ok(screen)
    }
}

fn release_screen(screen: usize, screens: &AvailableScreens) {
    let mut lock = screens.screens.lock().expect("lock shared data");
    lock[screen] = false;
}

fn main() {
    rocket::ignite()
        .mount("/", routes![getpdf, status])
        .manage(AvailableScreens {
            screens: Mutex::new(vec![false; 1]),
        })
        .launch();
}
