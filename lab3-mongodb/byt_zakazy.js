//  БД: byt_zakazy — обработка заказов в службе быта (вариант 8)
//  MongoDB 4.4+ / mongosh
//  Запуск:  mongosh --file byt_zakazy.js     (или вставить в MONGOSH внутри Compass)
//  Модель повторяет 3НФ-схему из лабораторной №2; позиции и история статусов
//  заказа встроены в документ заказа (массивы pozitsii и istoriya).

db = db.getSiblingDB("byt_zakazy")
db.dropDatabase()                      // чтобы скрипт можно было запускать повторно
db = db.getSiblingDB("byt_zakazy")

// ========== 1. KATEGORIYA_USLUGI ==========
db.kategoriya_uslugi.insertMany([
  { _id: 1,  nazvanie: "Ремонт обуви",             opisanie: "Набойки, молнии, подошвы" },
  { _id: 2,  nazvanie: "Химчистка",                opisanie: "Чистка верхней одежды и текстиля" },
  { _id: 3,  nazvanie: "Ремонт одежды",            opisanie: "Подгонка, замена фурнитуры" },
  { _id: 4,  nazvanie: "Ремонт бытовой техники",   opisanie: "Мелкая бытовая техника" },
  { _id: 5,  nazvanie: "Ремонт часов",             opisanie: "Механические и кварцевые часы" },
  { _id: 6,  nazvanie: "Изготовление ключей",      opisanie: "Дубликаты ключей" },
  { _id: 7,  nazvanie: "Ремонт ювелирных изделий", opisanie: "Пайка, чистка, смена вставок" },
  { _id: 8,  nazvanie: "Стирка и глажка",          opisanie: "Стирка, глажка, упаковка" },
  { _id: 9,  nazvanie: "Ремонт мебели",            opisanie: "Мелкий ремонт, перетяжка" },
  { _id: 10, nazvanie: "Фотоуслуги",               opisanie: "Фото на документы, печать" }
])

// ========== 2. DOLZHNOST ==========
db.dolzhnost.insertMany([
  { _id: 1,  nazvanie: "Директор",          oklad: 1800.00 },
  { _id: 2,  nazvanie: "Администратор",     oklad: 1100.00 },
  { _id: 3,  nazvanie: "Приёмщик",          oklad: 900.00  },
  { _id: 4,  nazvanie: "Мастер по обуви",   oklad: 1000.00 },
  { _id: 5,  nazvanie: "Портной",           oklad: 1000.00 },
  { _id: 6,  nazvanie: "Мастер по технике", oklad: 1200.00 },
  { _id: 7,  nazvanie: "Часовщик",          oklad: 1300.00 },
  { _id: 8,  nazvanie: "Кассир",            oklad: 850.00  },
  { _id: 9,  nazvanie: "Курьер",            oklad: 750.00  },
  { _id: 10, nazvanie: "Стажёр",            oklad: 600.00  }
])

// ========== 3. PUNKT_PRIEMA ==========
db.punkt_priema.insertMany([
  { _id: 1, nazvanie: "Пункт №1", adres: "Рига, ул. Бривибас, 10",  telefon: "+37120000001" },
  { _id: 2, nazvanie: "Пункт №2", adres: "Рига, ул. Матиса, 25",    telefon: "+37120000002" },
  { _id: 3, nazvanie: "Пункт №3", adres: "Рига, ул. Дзирнаву, 40",  telefon: "+37120000003" },
  { _id: 4, nazvanie: "Пункт №4", adres: "Рига, ул. Лачплеша, 62",  telefon: "+37120000004" },
  { _id: 5, nazvanie: "Центральный офис", adres: "Рига, ул. Элизабетес, 1", telefon: "+37120000005" }
])

// ========== 4. SOTRUDNIK ==========
db.sotrudnik.insertMany([
  { _id: 1,  imya: "Алексей",  familiya: "Кузнецов", otchestvo: "Петрович",   telefon: "+37121000001", data_priema: new Date("2020-01-15"), dolzhnost_id: 1,  punkt_id: 5 },
  { _id: 2,  imya: "Наталья",  familiya: "Попова",   otchestvo: "Ивановна",   telefon: "+37121000002", data_priema: new Date("2021-03-10"), dolzhnost_id: 2,  punkt_id: 1 },
  { _id: 3,  imya: "Анна",     familiya: "Иванова",  otchestvo: "Петровна",   telefon: "+37121000003", data_priema: new Date("2022-03-01"), dolzhnost_id: 3,  punkt_id: 1 },
  { _id: 4,  imya: "Мария",    familiya: "Орлова",   otchestvo: "Сергеевна",  telefon: "+37121000004", data_priema: new Date("2023-01-20"), dolzhnost_id: 3,  punkt_id: 2 },
  { _id: 5,  imya: "Олег",     familiya: "Сидоров",  otchestvo: "Иванович",   telefon: "+37121000005", data_priema: new Date("2021-06-15"), dolzhnost_id: 4,  punkt_id: 1 },
  { _id: 6,  imya: "Ирина",    familiya: "Крылова",  otchestvo: "Викторовна", telefon: "+37121000006", data_priema: new Date("2022-09-05"), dolzhnost_id: 5,  punkt_id: 2 },
  { _id: 7,  imya: "Михаил",   familiya: "Громов",   otchestvo: "Олегович",   telefon: "+37121000007", data_priema: new Date("2020-09-10"), dolzhnost_id: 6,  punkt_id: 3 },
  { _id: 8,  imya: "Виктор",   familiya: "Титов",    otchestvo: "Николаевич", telefon: "+37121000008", data_priema: new Date("2023-04-05"), dolzhnost_id: 7,  punkt_id: 3 },
  { _id: 9,  imya: "Светлана", familiya: "Егорова",  otchestvo: "Андреевна",  telefon: "+37121000009", data_priema: new Date("2023-07-01"), dolzhnost_id: 8,  punkt_id: 4 },
  { _id: 10, imya: "Юлия",     familiya: "Зайцева",  otchestvo: "Павловна",   telefon: "+37121000010", data_priema: new Date("2024-02-15"), dolzhnost_id: 10, punkt_id: 4 }
])

// ========== 5. KLIENT ==========
db.klient.insertMany([
  { _id: 1,  imya: "Павел",   familiya: "Петров",    otchestvo: "Андреевич",  telefon: "+37126000001", email: "petrov@example.com",    adres: "Рига, ул. Лачплеша, 5",   data_registratsii: new Date("2024-01-11") },
  { _id: 2,  imya: "Елена",   familiya: "Кузнецова", otchestvo: null,         telefon: "+37126000002", email: "kuznetsova@example.com", adres: "Рига, ул. Дзирнаву, 12", data_registratsii: new Date("2024-02-03") },
  { _id: 3,  imya: "Андрис",  familiya: "Лиепа",     otchestvo: null,         telefon: "+37126000003", email: null,                     adres: null,                      data_registratsii: new Date("2024-03-18") },
  { _id: 4,  imya: "Ольга",   familiya: "Новикова",  otchestvo: "Сергеевна",  telefon: "+37126000004", email: "olga@example.com",      adres: "Рига, ул. Тербатас, 15",  data_registratsii: new Date("2024-05-02") },
  { _id: 5,  imya: "Дмитрий", familiya: "Орлов",     otchestvo: "Викторович", telefon: "+37126000005", email: "dmitry@example.com",    adres: "Рига, ул. Бривибас, 100", data_registratsii: new Date("2024-06-14") },
  { _id: 6,  imya: "Мария",   familiya: "Козлова",   otchestvo: "Андреевна",  telefon: "+37126000006", email: "maria@example.com",     adres: "Юрмала, ул. Йомас, 30",   data_registratsii: new Date("2024-08-21") },
  { _id: 7,  imya: "Янис",    familiya: "Берзиньш",  otchestvo: null,         telefon: "+37126000007", email: "janis@example.com",     adres: "Рига, ул. Матиса, 8",     data_registratsii: new Date("2025-01-09") },
  { _id: 8,  imya: "Елена",   familiya: "Волкова",   otchestvo: "Дмитриевна", telefon: "+37126000008", email: "volkova@example.com",   adres: "Рига, ул. Авоту, 22",     data_registratsii: new Date("2025-04-27") },
  { _id: 9,  imya: "Артём",   familiya: "Соколов",   otchestvo: "Олегович",   telefon: "+37126000009", email: "artem@example.com",     adres: "Рига, ул. Маскавас, 75",  data_registratsii: new Date("2025-09-30") },
  { _id: 10, imya: "Ксения",  familiya: "Лебедева",  otchestvo: "Павловна",   telefon: "+37126000010", email: "ksenia@example.com",    adres: "Рига, ул. Кр. Барона, 3", data_registratsii: new Date("2026-02-12") }
])

// ========== 6. USLUGA ==========
db.usluga.insertMany([
  { _id: 1,  nazvanie: "Замена набоек",            kategoriya_id: 1, tsena: 8.00,  srok_dney: 1 },
  { _id: 2,  nazvanie: "Замена молнии на обуви",   kategoriya_id: 1, tsena: 12.00, srok_dney: 2 },
  { _id: 3,  nazvanie: "Химчистка пальто",         kategoriya_id: 2, tsena: 20.00, srok_dney: 3 },
  { _id: 4,  nazvanie: "Химчистка куртки",         kategoriya_id: 2, tsena: 15.00, srok_dney: 3 },
  { _id: 5,  nazvanie: "Подгонка брюк по длине",   kategoriya_id: 3, tsena: 7.00,  srok_dney: 1 },
  { _id: 6,  nazvanie: "Ремонт утюга",             kategoriya_id: 4, tsena: 18.00, srok_dney: 5 },
  { _id: 7,  nazvanie: "Замена батарейки в часах", kategoriya_id: 5, tsena: 6.00,  srok_dney: 1 },
  { _id: 8,  nazvanie: "Дубликат ключа",           kategoriya_id: 6, tsena: 4.00,  srok_dney: 1 },
  { _id: 9,  nazvanie: "Чистка серебряных изделий",kategoriya_id: 7, tsena: 9.00,  srok_dney: 2 },
  { _id: 10, nazvanie: "Фото на документы",        kategoriya_id: 10, tsena: 5.00, srok_dney: 1 }
])

// ========== 7. STATUS_ZAKAZA ==========
db.status_zakaza.insertMany([
  { _id: 1, nazvanie: "Принят",         konechnyy: false },
  { _id: 2, nazvanie: "В работе",       konechnyy: false },
  { _id: 3, nazvanie: "Готов к выдаче", konechnyy: false },
  { _id: 4, nazvanie: "Выдан",          konechnyy: true  },
  { _id: 5, nazvanie: "Отменён",        konechnyy: true  }
])

// ========== 8. SPOSOB_OPLATY ==========
db.sposob_oplaty.insertMany([
  { _id: 1, nazvanie: "Наличные" },
  { _id: 2, nazvanie: "Банковская карта" },
  { _id: 3, nazvanie: "Безналичный перевод" },
  { _id: 4, nazvanie: "Подарочный сертификат" }
])

// ========== 9. ZAKAZ (с позициями и историей статусов) ==========
db.zakaz.insertMany([
  { _id: 1, nomer_zakaza: "ZK-2026-001", klient_id: 1, punkt_id: 1, priemshchik_id: 3, status_id: 4,
    data_sozdaniya: new Date("2026-10-01T10:00:00"), plan_data: new Date("2026-10-04"), fakt_data: new Date("2026-10-03"), primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 3, ispolnitel_id: 5, kolichestvo: 1, tsena_fiks: 20.00 },
                { nomer: 2, usluga_id: 5, ispolnitel_id: 6, kolichestvo: 1, tsena_fiks: 7.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-01T10:00:00"), sotrudnik_id: 3 },
                { status_id: 2, data: new Date("2026-10-01T14:00:00"), sotrudnik_id: 5 },
                { status_id: 3, data: new Date("2026-10-03T12:00:00"), sotrudnik_id: 5 },
                { status_id: 4, data: new Date("2026-10-03T17:30:00"), sotrudnik_id: 3 } ] },
  { _id: 2, nomer_zakaza: "ZK-2026-002", klient_id: 2, punkt_id: 2, priemshchik_id: 4, status_id: 2,
    data_sozdaniya: new Date("2026-10-14T11:20:00"), plan_data: new Date("2026-10-19"), fakt_data: null, primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 6, ispolnitel_id: 7, kolichestvo: 1, tsena_fiks: 18.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-14T11:20:00"), sotrudnik_id: 4 },
                { status_id: 2, data: new Date("2026-10-15T09:00:00"), sotrudnik_id: 7 } ] },
  { _id: 3, nomer_zakaza: "ZK-2026-003", klient_id: 3, punkt_id: 1, priemshchik_id: 3, status_id: 1,
    data_sozdaniya: new Date("2026-10-16T09:30:00"), plan_data: new Date("2026-10-17"), fakt_data: null, primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 1, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 8.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-16T09:30:00"), sotrudnik_id: 3 } ] },
  { _id: 4, nomer_zakaza: "ZK-2026-004", klient_id: 4, punkt_id: 3, priemshchik_id: 9, status_id: 3,
    data_sozdaniya: new Date("2026-10-08T12:00:00"), plan_data: new Date("2026-10-10"), fakt_data: new Date("2026-10-09"), primechanie: "Позвонить клиенту",
    pozitsii: [ { nomer: 1, usluga_id: 7, ispolnitel_id: 8, kolichestvo: 2, tsena_fiks: 6.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-08T12:00:00"), sotrudnik_id: 9 },
                { status_id: 2, data: new Date("2026-10-08T15:00:00"), sotrudnik_id: 8 },
                { status_id: 3, data: new Date("2026-10-09T11:00:00"), sotrudnik_id: 8 } ] },
  { _id: 5, nomer_zakaza: "ZK-2026-005", klient_id: 5, punkt_id: 4, priemshchik_id: 9, status_id: 4,
    data_sozdaniya: new Date("2026-09-28T10:15:00"), plan_data: new Date("2026-10-01"), fakt_data: new Date("2026-10-01"), primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 4, ispolnitel_id: 5, kolichestvo: 1, tsena_fiks: 15.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-09-28T10:15:00"), sotrudnik_id: 9 },
                { status_id: 2, data: new Date("2026-09-29T09:00:00"), sotrudnik_id: 5 },
                { status_id: 3, data: new Date("2026-10-01T10:00:00"), sotrudnik_id: 5 },
                { status_id: 4, data: new Date("2026-10-01T16:40:00"), sotrudnik_id: 9 } ] },
  { _id: 6, nomer_zakaza: "ZK-2026-006", klient_id: 6, punkt_id: 2, priemshchik_id: 4, status_id: 5,
    data_sozdaniya: new Date("2026-10-05T13:00:00"), plan_data: new Date("2026-10-07"), fakt_data: null, primechanie: "Отменён клиентом",
    pozitsii: [ { nomer: 1, usluga_id: 2, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 12.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-05T13:00:00"), sotrudnik_id: 4 },
                { status_id: 5, data: new Date("2026-10-05T18:00:00"), sotrudnik_id: 4 } ] },
  { _id: 7, nomer_zakaza: "ZK-2026-007", klient_id: 7, punkt_id: 1, priemshchik_id: 3, status_id: 4,
    data_sozdaniya: new Date("2026-10-02T09:00:00"), plan_data: new Date("2026-10-03"), fakt_data: new Date("2026-10-03"), primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 8, ispolnitel_id: 5, kolichestvo: 3, tsena_fiks: 4.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-02T09:00:00"), sotrudnik_id: 3 },
                { status_id: 3, data: new Date("2026-10-02T09:30:00"), sotrudnik_id: 5 },
                { status_id: 4, data: new Date("2026-10-03T10:00:00"), sotrudnik_id: 3 } ] },
  { _id: 8, nomer_zakaza: "ZK-2026-008", klient_id: 8, punkt_id: 3, priemshchik_id: 9, status_id: 2,
    data_sozdaniya: new Date("2026-10-13T16:00:00"), plan_data: new Date("2026-10-15"), fakt_data: null, primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 9, ispolnitel_id: 8, kolichestvo: 1, tsena_fiks: 9.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-13T16:00:00"), sotrudnik_id: 9 },
                { status_id: 2, data: new Date("2026-10-14T09:00:00"), sotrudnik_id: 8 } ] },
  { _id: 9, nomer_zakaza: "ZK-2026-009", klient_id: 9, punkt_id: 4, priemshchik_id: 9, status_id: 1,
    data_sozdaniya: new Date("2026-10-16T10:45:00"), plan_data: new Date("2026-10-17"), fakt_data: null, primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 10, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 5.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-16T10:45:00"), sotrudnik_id: 9 } ] },
  { _id: 10, nomer_zakaza: "ZK-2026-010", klient_id: 10, punkt_id: 2, priemshchik_id: 4, status_id: 3,
    data_sozdaniya: new Date("2026-10-10T11:30:00"), plan_data: new Date("2026-10-13"), fakt_data: new Date("2026-10-12"), primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: 3, ispolnitel_id: 6, kolichestvo: 1, tsena_fiks: 20.00 },
                { nomer: 2, usluga_id: 4, ispolnitel_id: 6, kolichestvo: 1, tsena_fiks: 15.00 } ],
    istoriya: [ { status_id: 1, data: new Date("2026-10-10T11:30:00"), sotrudnik_id: 4 },
                { status_id: 2, data: new Date("2026-10-10T15:00:00"), sotrudnik_id: 6 },
                { status_id: 3, data: new Date("2026-10-12T12:00:00"), sotrudnik_id: 6 } ] }
])

// ========== 10. PLATEZH ==========
db.platezh.insertMany([
  { _id: 1,  zakaz_id: 1,  sposob_id: 2, summa: 27.00, data_platezha: new Date("2026-10-03T17:30:00"), prinyal_id: 3 },
  { _id: 2,  zakaz_id: 2,  sposob_id: 1, summa: 5.00,  data_platezha: new Date("2026-10-14T11:25:00"), prinyal_id: 4 },
  { _id: 3,  zakaz_id: 4,  sposob_id: 2, summa: 12.00, data_platezha: new Date("2026-10-08T12:05:00"), prinyal_id: 9 },
  { _id: 4,  zakaz_id: 5,  sposob_id: 1, summa: 15.00, data_platezha: new Date("2026-10-01T16:40:00"), prinyal_id: 9 },
  { _id: 5,  zakaz_id: 7,  sposob_id: 1, summa: 12.00, data_platezha: new Date("2026-10-03T10:00:00"), prinyal_id: 3 },
  { _id: 6,  zakaz_id: 8,  sposob_id: 3, summa: 9.00,  data_platezha: new Date("2026-10-13T16:10:00"), prinyal_id: 9 },
  { _id: 7,  zakaz_id: 10, sposob_id: 2, summa: 20.00, data_platezha: new Date("2026-10-10T11:35:00"), prinyal_id: 4 },
  { _id: 8,  zakaz_id: 10, sposob_id: 2, summa: 15.00, data_platezha: new Date("2026-10-12T12:30:00"), prinyal_id: 4 },
  { _id: 9,  zakaz_id: 3,  sposob_id: 4, summa: 8.00,  data_platezha: new Date("2026-10-16T09:35:00"), prinyal_id: 3 },
  { _id: 10, zakaz_id: 9,  sposob_id: 1, summa: 5.00,  data_platezha: new Date("2026-10-16T10:50:00"), prinyal_id: 9 }
])

print("========== ИТОГ ==========")
db.getCollectionNames().forEach(function(c) {
  print(c + ": " + db[c].countDocuments());
})
print("==========================")
