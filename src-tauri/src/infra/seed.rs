// src-tauri/src/infra/seed.rs
use crate::domain::{Cancion, Columna, Estrofa, Evento, Recuerdo};

fn col(n7: &str, n6: &str) -> Columna {
    Columna { nota7: n7.into(), nota6: n6.into() }
}

fn est(columnas: Vec<Columna>) -> Estrofa {
    Estrofa { columnas, bis: false }
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

pub fn eventos_demo() -> Vec<Evento> {
    vec![
        Evento {
            id: "e1".into(),
            titulo: "Fiesta Patronal".into(),
            descripcion: "Presentación central del grupo en la fiesta patronal de Juliaca. Traer instrumentos y uniforme completo.".into(),
            lugar: "Plaza de Armas, Juliaca".into(),
            fecha: "2026-10-15T19:00:00".into(),
            lat: Some(-15.4994),
            lng: Some(-70.1333),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
        Evento {
            id: "e2".into(),
            titulo: "Aniversario del Grupo".into(),
            descripcion: "Celebración por el aniversario del C.I.A.C. Allin Kawsay. Cena de confraternidad y presentación especial.".into(),
            lugar: "Local institucional, Juliaca".into(),
            fecha: "2026-11-02T18:30:00".into(),
            lat: Some(-15.4985),
            lng: Some(-70.1320),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
        Evento {
            id: "e3".into(),
            titulo: "Concurso Regional de Sikuris".into(),
            descripcion: "Participación en el concurso regional. Ensayo general el día anterior a las 20:00.".into(),
            lugar: "Coliseo Cerrado, Puno".into(),
            fecha: "2026-12-08T16:00:00".into(),
            lat: Some(-15.8402),
            lng: Some(-70.0199),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
        Evento {
            id: "e4".into(),
            titulo: "Ensayo General — Aniversario".into(),
            descripcion: "Ensayo obligatorio previo al aniversario. Repaso de todo el repertorio.".into(),
            lugar: "Local institucional".into(),
            fecha: "2026-09-20T20:00:00".into(),
            lat: None,
            lng: None,
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
    ]
}

fn foto(seed: &str) -> String {
    format!("https://picsum.photos/seed/{seed}/800/600")
}

fn foto_vertical(seed: &str) -> String {
    format!("https://picsum.photos/seed/{seed}/600/800")
}

pub fn recuerdos_demo() -> Vec<Recuerdo> {
    vec![
        Recuerdo {
            id: "r1".into(),
            titulo: "Fiesta Patronal 2025".into(),
            descripcion: "Presentación inolvidable en la plaza de armas. El público no dejaba de aplaudir.".into(),
            fotos: vec![
                foto("allin_fp1"),
                foto_vertical("allin_fp2"),
                foto("allin_fp3"),
                foto_vertical("allin_fp4"),
                foto("allin_fp5"),
            ],
            videos: vec!["demo_video_1".into()],
            fecha: "2025-10-15T20:00:00".into(),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
        Recuerdo {
            id: "r2".into(),
            titulo: "Aniversario 2024".into(),
            descripcion: "Noche de confraternidad y música. Los fundadores nos acompañaron.".into(),
            fotos: vec![
                foto("allin_an1"),
                foto("allin_an2"),
                foto_vertical("allin_an3"),
                foto("allin_an4"),
            ],
            videos: vec![],
            fecha: "2024-11-02T19:30:00".into(),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
        Recuerdo {
            id: "r3".into(),
            titulo: "Ensayo en el local".into(),
            descripcion: "Preparativos para el concurso regional. Mucho esfuerzo y dedicación.".into(),
            fotos: vec![
                foto_vertical("allin_en1"),
                foto("allin_en2"),
                foto("allin_en3"),
            ],
            videos: vec![],
            fecha: "2024-08-20T21:00:00".into(),
            creado_por: "admin".into(),
            creador_nombre: "Directiva".into(),
        },
    ]
}