// src-tauri/src/infra/seed.rs
use crate::domain::{Cancion, Columna, Estrofa};

fn col(n7: &str, n6: &str) -> Columna {
    Columna {
        nota7: n7.into(),
        nota6: n6.into(),
    }
}

fn est(columnas: Vec<Columna>) -> Estrofa {
    Estrofa {
        columnas,
        bis: false,
    }
}

pub fn canciones_demo() -> Vec<Cancion> {
    vec![
        Cancion {
            id: "c1".into(),
            titulo: "Adiós Conima".into(),
            autor: "Anónimo".into(),
            ritmo: "Huayño".into(),
            region: "Puno".into(),
            imagen_url: String::new(),
            audio_url: String::new(),
            video_url: String::new(),
            descripcion: "Huayño tradicional del altiplano peruano.".into(),
            reproducciones: 342,
            estrofas: vec![
                est(vec![
                    col("1", "5"),
                    col("2", "6"),
                    col("3", "7"),
                    col("3", "6"),
                    col("2", "5"),
                ]),
                est(vec![
                    col("5", "2"),
                    col("6", "3"),
                    col("7", "4"),
                    col("6", "3"),
                ]),
            ],
            letra: "Adiós Conima, tierra querida,\ndonde he pasado mi juventud.\nAdiós Conima, tierra querida,\nno te olvidaré jamás.".into(),
            tags: vec!["tradicional".into(), "altiplano".into()],
        },
        Cancion {
            id: "c2".into(),
            titulo: "Aguila Negra".into(),
            autor: "Anónimo".into(),
            ritmo: "Huayño".into(),
            region: "Cusco".into(),
            imagen_url: String::new(),
            audio_url: String::new(),
            video_url: String::new(),
            descripcion: "Huayño clásico del repertorio de sikuris.".into(),
            reproducciones: 218,
            estrofas: vec![est(vec![
                col("3", "7"),
                col("2", "6"),
                col("1", "5"),
                col("2", "6"),
                col("3", "7"),
            ])],
            letra: "Águila negra que vas volando,\nllévame lejos de este lugar.\nÁguila negra que vas volando,\nllévame al cielo, quiero soñar.".into(),
            tags: vec!["tradicional".into()],
        },
        Cancion {
            id: "c3".into(),
            titulo: "Fiesta de mi Pueblo".into(),
            autor: "Anónimo".into(),
            ritmo: "Carnaval".into(),
            region: "Juliaca".into(),
            imagen_url: String::new(),
            audio_url: String::new(),
            video_url: String::new(),
            descripcion: "Carnaval juliaqueño, ritmo festivo y colorido.".into(),
            reproducciones: 156,
            estrofas: vec![
                est(vec![
                    col("1", "4"),
                    col("2", "5"),
                    col("3", "6"),
                ]),
                est(vec![
                    col("6", "3"),
                    col("5", "2"),
                    col("4", "1"),
                ]),
            ],
            letra: "En la fiesta de mi pueblo\ntodos bailan sin parar.\nEn la fiesta de mi pueblo\nhay que alegría sin igual.".into(),
            tags: vec!["carnaval".into(), "juliaca".into()],
        },
        Cancion {
            id: "c4".into(),
            titulo: "Qhapaq Qolla".into(),
            autor: "Anónimo".into(),
            ritmo: "Qhapaq Qolla".into(),
            region: "Puno".into(),
            imagen_url: String::new(),
            audio_url: String::new(),
            video_url: String::new(),
            descripcion: "Danza ritual de los comerciantes del altiplano.".into(),
            reproducciones: 501,
            estrofas: vec![est(vec![
                col("2", "6"),
                col("3", "7"),
                col("4", "1"),
                col("5", "2"),
                col("6", "3"),
            ])],
            letra: "Qhapaq Qolla, señor de las alturas,\nguía mi camino con tu bendición.\nQhapaq Qolla, señor de las alturas,\nprotege a mi pueblo con tu bendición.".into(),
            tags: vec!["ritual".into(), "qhapaq".into()],
        },
        Cancion {
            id: "c5".into(),
            titulo: "Sikuri de la Noche".into(),
            autor: "Anónimo".into(),
            ritmo: "Sikuri".into(),
            region: "Arequipa".into(),
            imagen_url: String::new(),
            audio_url: String::new(),
            video_url: String::new(),
            descripcion: "Sikuri moderno con ritmo hipnótico.".into(),
            reproducciones: 89,
            estrofas: vec![est(vec![
                col("7", "4"),
                col("6", "3"),
                col("5", "2"),
            ])],
            letra: "Bajo la luna del altiplano\nlos sikuris tocan sin cesar.\nBajo la luna del altiplano\nsu música nos hace soñar.".into(),
            tags: vec!["sikuri".into(), "moderno".into()],
        },
    ]
}