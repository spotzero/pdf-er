#![feature(proc_macro_hygiene)]
#![feature(decl_macro)]

#[macro_use] extern crate rocket;

#[cfg(test)] mod tests;

use rocket::request::Form;
use rocket::response::status;
use rocket::response::Response;
use rocket::http::Status;
use rocket::http::ContentType;
use std::io::Cursor;
use std::process::Command;
use std::fs;
use uuid::Uuid;
use validator;

#[derive(FromForm)]
struct RemoteURL {
    url: String
}

#[get("/?<remoteurl..>")]
fn getpdf(remoteurl: Option<Form<RemoteURL>>) -> Result<Response<'static>, status::Custom<String>> {
    if let Some(remoteurl) = remoteurl {
        if validator::validate_url(&remoteurl.url) {
            let name = Uuid::new_v4().to_string();
            let pdf_path = format!("/output/{}.pdf", name);
            let pdf_status = Command::new("/app/bin/generate-pdf.sh")
                .env("URL",&remoteurl.url)
                .env("PDFNAME",&name)
                .status();
            if let Err(e) = pdf_status {
              return Err(status::Custom(Status::ServiceUnavailable, e.to_string()))
            }

            let pdf_file = fs::read(pdf_path);
            if let Err(e) = pdf_file {
              return Err(status::Custom(Status::ServiceUnavailable, e.to_string()))
            }

            let pdf_file = pdf_file.unwrap();

            Command::new("rm")
              .arg("-f")
              .arg(format!("/output/{}*", name))
              .spawn()
              .unwrap();

            let response = Response::build()
              .status(Status::Ok)
              .header(ContentType::PDF)
              .sized_body(Cursor::new(pdf_file))
              .finalize();
            Ok(response)
        } else {
            Err(status::Custom(Status::NotAcceptable, "URL doesn't appear to be valid.".into()))
        }
    } else {
        Err(status::Custom(Status::NotAcceptable, "You must specify a URL in the GET parameter to use this service (add: ?url=<URI>)".into()))
    }
}

fn main() {
    rocket::ignite().mount("/", routes![getpdf]).launch();
}
