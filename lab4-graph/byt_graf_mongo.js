//  БД: byt_graf — социальный граф персонажей службы быта (вариант 8, лаб. №4)
//  MongoDB: граф хранится двумя коллекциями
//    uzly  — узлы (группы и персонажи)
//    rebra — рёбра (ot -> do, тип связи, характеристики)
//  Симметричные связи (FRIEND_OF, FAMILY_OF, NEIGHBOR_OF, COLLEAGUE_OF,
//  NEGOTIATES_WITH) хранятся одним ребром, napravlennoe: false.
//  Вставить в MONGOSH внутри Compass.

db = db.getSiblingDB("byt_graf")
db.dropDatabase()
db = db.getSiblingDB("byt_graf")

// ========== 1. UZLY ==========
db.uzly.insertMany([
  { _id: "gr_klienty", tip_uzla: "Gruppa", nazvanie: "Клиенты", opisanie: "Конечные потребители услуг", pervichnaya_tsel: "Быстро и недорого решить бытовую проблему" },
  { _id: "gr_sotrudniki", tip_uzla: "Gruppa", nazvanie: "Сотрудники", opisanie: "Принимают заказы и выполняют работы", pervichnaya_tsel: "Обработать заказ в срок и без ошибок" },
  { _id: "gr_partnery", tip_uzla: "Gruppa", nazvanie: "Партнёры", opisanie: "Поставщики и логистика", pervichnaya_tsel: "Регулярные договорные поставки и доставка" },
  { _id: "pavel", tip_uzla: "Persona", gruppa_id: "gr_klienty", imya: "Павел", familiya: "Петров", vozrast: 34, gorod: "Рига", foto: "petrov.jpg", biografiya: "Менеджер по продажам, живёт один, ценит своё время", opyt: "Пользуется службой 3 года, около 12 заказов", gotovnost: "высокая", tseli: "Сдать вещи рядом с домом и забрать в срок" },
  { _id: "elena", tip_uzla: "Persona", gruppa_id: "gr_klienty", imya: "Елена", familiya: "Кузнецова", vozrast: 42, gorod: "Рига", foto: "kuznetsova.jpg", biografiya: "Мать двоих детей, много вещей в химчистку и ремонт", opyt: "Постоянный клиент, 8 заказов", gotovnost: "высокая", tseli: "Сэкономить время семьи, принять заказ одним визитом" },
  { _id: "andris", tip_uzla: "Persona", gruppa_id: "gr_klienty", imya: "Андрис", familiya: "Лиепа", vozrast: 67, gorod: "Рига", foto: "liepa.jpg", biografiya: "Пенсионер, не пользуется онлайн-сервисами", opyt: "Ключи и ремонт обуви раз в полгода", gotovnost: "средняя", tseli: "Доверить мелкий ремонт знакомому мастеру" },
  { _id: "olga", tip_uzla: "Persona", gruppa_id: "gr_klienty", imya: "Ольга", familiya: "Новикова", vozrast: 29, gorod: "Рига", foto: "novikova.jpg", biografiya: "Дизайнер, работает удалённо, следит за модой", opyt: "Новый клиент, 2 заказа", gotovnost: "средняя", tseli: "Подогнать одежду и узнать срок без звонков" },
  { _id: "dmitry", tip_uzla: "Persona", gruppa_id: "gr_klienty", imya: "Дмитрий", familiya: "Орлов", vozrast: 45, gorod: "Рига", foto: "orlov.jpg", biografiya: "Владелец кафе, отдаёт форму персонала в стирку", opyt: "Корпоративный клиент, еженедельные заказы", gotovnost: "очень высокая", tseli: "Стабильные сроки и скидка на объём" },
  { _id: "anna", tip_uzla: "Persona", gruppa_id: "gr_sotrudniki", imya: "Анна", familiya: "Иванова", vozrast: 31, gorod: "Рига", dolzhnost: "Приёмщик", foto: "ivanova.jpg", biografiya: "В службе с 2022 года, общительная", opyt: "Принимает до 25 заказов в день", tseli: "Оформить заказ без ошибок и сразу назвать срок" },
  { _id: "oleg", tip_uzla: "Persona", gruppa_id: "gr_sotrudniki", imya: "Олег", familiya: "Сидоров", vozrast: 48, gorod: "Рига", dolzhnost: "Мастер по обуви", foto: "sidorov.jpg", biografiya: "Мастер с 20-летним стажем", opyt: "Около 15 работ в день", tseli: "Получать заказы с указанием дефекта" },
  { _id: "irina", tip_uzla: "Persona", gruppa_id: "gr_sotrudniki", imya: "Ирина", familiya: "Крылова", vozrast: 38, gorod: "Юрмала", dolzhnost: "Портной", foto: "krylova.jpg", biografiya: "Подгоняет одежду, принимает корпоративные заказы", opyt: "В службе с 2022 года", tseli: "Видеть очередь работ и срочные заказы" },
  { _id: "natalya", tip_uzla: "Persona", gruppa_id: "gr_sotrudniki", imya: "Наталья", familiya: "Попова", vozrast: 44, gorod: "Рига", dolzhnost: "Администратор", foto: "popova.jpg", biografiya: "Руководит пунктом приёма, отвечает за сроки и жалобы", opyt: "Работает с 2021 года", tseli: "Контролировать статусы заказов и загрузку мастеров" },
  { _id: "mihail", tip_uzla: "Persona", gruppa_id: "gr_sotrudniki", imya: "Михаил", familiya: "Громов", vozrast: 52, gorod: "Рига", dolzhnost: "Мастер по технике", foto: "gromov.jpg", biografiya: "Ремонтирует мелкую бытовую технику", opyt: "Работает с 2020 года", tseli: "Вовремя получать запчасти и заказы" },
  { _id: "janis", tip_uzla: "Persona", gruppa_id: "gr_partnery", imya: "Янис", familiya: "Берзиньш", vozrast: 40, gorod: "Рига", organizatsiya: "SIA Furnitura", foto: "berzins.jpg", biografiya: "Владелец оптовой компании по поставке фурнитуры", opyt: "Сотрудничает 4 года", gotovnost: "высокая", tseli: "Крупные регулярные заказы по договору" },
  { _id: "artem", tip_uzla: "Persona", gruppa_id: "gr_partnery", imya: "Артём", familiya: "Соколов", vozrast: 36, gorod: "Рига", organizatsiya: "ИП Соколов, курьер", foto: "sokolov.jpg", biografiya: "Возит заказы клиентам, которые не могут прийти сами", opyt: "Сотрудничает 2 года", gotovnost: "высокая", tseli: "Плотный маршрут и предсказуемое расписание" }
])

// ========== 2. REBRA ==========
db.rebra.insertMany([
  { _id: 1, ot: "pavel", do: "gr_klienty", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 2, ot: "elena", do: "gr_klienty", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 3, ot: "andris", do: "gr_klienty", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 4, ot: "olga", do: "gr_klienty", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 5, ot: "dmitry", do: "gr_klienty", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 6, ot: "anna", do: "gr_sotrudniki", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 7, ot: "oleg", do: "gr_sotrudniki", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 8, ot: "irina", do: "gr_sotrudniki", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 9, ot: "natalya", do: "gr_sotrudniki", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 10, ot: "mihail", do: "gr_sotrudniki", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 11, ot: "janis", do: "gr_partnery", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 12, ot: "artem", do: "gr_partnery", tip: "BELONGS_TO", napravlennoe: true },
  { _id: 13, ot: "pavel", do: "dmitry", tip: "FRIEND_OF", napravlennoe: false, since: 2015, sila: 5 },
  { _id: 14, ot: "pavel", do: "andris", tip: "NEIGHBOR_OF", napravlennoe: false, since: 2019, sila: 3 },
  { _id: 15, ot: "pavel", do: "olga", tip: "FRIEND_OF", napravlennoe: false, since: 2021, sila: 3 },
  { _id: 16, ot: "elena", do: "olga", tip: "FAMILY_OF", napravlennoe: false, since: 1984, sila: 5, rodstvo: "сестра" },
  { _id: 17, ot: "pavel", do: "elena", tip: "RECOMMENDED", napravlennoe: true, data: new Date("2024-03-10") },
  { _id: 18, ot: "elena", do: "olga", tip: "RECOMMENDED", napravlennoe: true, data: new Date("2025-06-02") },
  { _id: 19, ot: "dmitry", do: "andris", tip: "RECOMMENDED", napravlennoe: true, data: new Date("2024-11-20") },
  { _id: 20, ot: "dmitry", do: "andris", tip: "FRIEND_OF", napravlennoe: false, since: 2018, sila: 2 },
  { _id: 21, ot: "anna", do: "pavel", tip: "SERVES", napravlennoe: true, zakazov: 7, poslednyaya_data: new Date("2026-10-03") },
  { _id: 22, ot: "oleg", do: "pavel", tip: "SERVES", napravlennoe: true, zakazov: 5, poslednyaya_data: new Date("2026-10-03") },
  { _id: 23, ot: "anna", do: "andris", tip: "SERVES", napravlennoe: true, zakazov: 4, poslednyaya_data: new Date("2026-10-02") },
  { _id: 24, ot: "irina", do: "olga", tip: "SERVES", napravlennoe: true, zakazov: 2, poslednyaya_data: new Date("2026-10-12") },
  { _id: 25, ot: "mihail", do: "elena", tip: "SERVES", napravlennoe: true, zakazov: 3, poslednyaya_data: new Date("2026-10-15") },
  { _id: 26, ot: "anna", do: "dmitry", tip: "SERVES", napravlennoe: true, zakazov: 20, poslednyaya_data: new Date("2026-10-14") },
  { _id: 27, ot: "irina", do: "dmitry", tip: "SERVES", napravlennoe: true, zakazov: 18, poslednyaya_data: new Date("2026-10-14") },
  { _id: 28, ot: "oleg", do: "andris", tip: "SERVES", napravlennoe: true, zakazov: 3, poslednyaya_data: new Date("2026-09-20") },
  { _id: 29, ot: "natalya", do: "anna", tip: "MANAGES", napravlennoe: true, since: 2022 },
  { _id: 30, ot: "natalya", do: "oleg", tip: "MANAGES", napravlennoe: true, since: 2021 },
  { _id: 31, ot: "natalya", do: "irina", tip: "MANAGES", napravlennoe: true, since: 2022 },
  { _id: 32, ot: "natalya", do: "mihail", tip: "MANAGES", napravlennoe: true, since: 2021 },
  { _id: 33, ot: "oleg", do: "anna", tip: "COLLEAGUE_OF", napravlennoe: false, since: 2022, sila: 4 },
  { _id: 34, ot: "oleg", do: "irina", tip: "COLLEAGUE_OF", napravlennoe: false, since: 2022, sila: 3 },
  { _id: 35, ot: "oleg", do: "mihail", tip: "COLLEAGUE_OF", napravlennoe: false, since: 2021, sila: 4 },
  { _id: 36, ot: "irina", do: "mihail", tip: "COLLEAGUE_OF", napravlennoe: false, since: 2022, sila: 3 },
  { _id: 37, ot: "anna", do: "irina", tip: "COLLEAGUE_OF", napravlennoe: false, since: 2022, sila: 4 },
  { _id: 38, ot: "anna", do: "pavel", tip: "FRIEND_OF", napravlennoe: false, since: 2023, sila: 3 },
  { _id: 39, ot: "mihail", do: "elena", tip: "FRIEND_OF", napravlennoe: false, since: 2020, sila: 5 },
  { _id: 40, ot: "janis", do: "oleg", tip: "SUPPLIES", napravlennoe: true, predmet: "фурнитура", chastota: "раз в неделю" },
  { _id: 41, ot: "janis", do: "irina", tip: "SUPPLIES", napravlennoe: true, predmet: "ткани и нитки", chastota: "раз в 2 недели" },
  { _id: 42, ot: "janis", do: "mihail", tip: "SUPPLIES", napravlennoe: true, predmet: "запчасти", chastota: "раз в месяц" },
  { _id: 43, ot: "natalya", do: "janis", tip: "NEGOTIATES_WITH", napravlennoe: false, since: 2022, dogovor: "поставка фурнитуры" },
  { _id: 44, ot: "natalya", do: "artem", tip: "NEGOTIATES_WITH", napravlennoe: false, since: 2024, dogovor: "доставка заказов" },
  { _id: 45, ot: "artem", do: "elena", tip: new Date("ELIVERS_TO"), napravlennoe: true, zakazov: 6 }
])

db.rebra.createIndex({ ot: 1 })
db.rebra.createIndex({ do: 1 })
db.rebra.createIndex({ tip: 1 })

print("Узлов: " + db.uzly.countDocuments() + ", рёбер: " + db.rebra.countDocuments())

// ====================================================================
//                    ЗАПРОСЫ ДЛЯ СКРИНШОТОВ
// ====================================================================

// ===== 3.1 Количество узлов и рёбер (15 и 45) =====
db.uzly.countDocuments()
db.rebra.countDocuments()

// ===== 3.2 Узлы по типам =====
db.uzly.aggregate([ { $group: { _id: "$tip_uzla", kolichestvo: { $sum: 1 } } } ])

// ===== 3.3 Рёбра по типам =====
db.rebra.aggregate([
  { $group: { _id: "$tip", kolichestvo: { $sum: 1 } } },
  { $sort: { kolichestvo: -1 } }
])

// ===== 3.4 Персонажи по группам =====
db.uzly.aggregate([
  { $match: { tip_uzla: "Persona" } },
  { $group: { _id: "$gruppa_id", person: { $sum: 1 }, imena: { $push: { $concat: ["$imya", " ", "$familiya"] } } } }
])

// ===== 3.5 Степень узла: у кого больше всего связей =====
db.rebra.aggregate([
  { $match: { tip: { $ne: "BELONGS_TO" } } },
  { $project: { u: ["$ot", "$do"] } },
  { $unwind: "$u" },
  { $group: { _id: "$u", stepen: { $sum: 1 } } },
  { $sort: { stepen: -1 } },
  { $limit: 5 }
])

// ===== 3.6 Друзья Павла (симметричная связь: ищем в обе стороны) =====
db.rebra.find(
  { tip: "FRIEND_OF", $or: [ { ot: "pavel" }, { do: "pavel" } ] },
  { _id: 0, ot: 1, do: 1, since: 1, sila: 1 }
)

// ===== 3.7 Цепочка рекомендаций от Павла (обход графа $graphLookup) =====
db.uzly.aggregate([
  { $match: { _id: "pavel" } },
  { $graphLookup: {
      from: "rebra", startWith: "$_id", connectFromField: "do", connectToField: "ot",
      as: "tsepochka", depthField: "shag",
      restrictSearchWithMatch: { tip: "RECOMMENDED" } } },
  { $project: { _id: 0, imya: 1, "tsepochka.ot": 1, "tsepochka.do": 1, "tsepochka.shag": 1 } }
])

// ===== 3.8 Загрузка сотрудников: клиентов и заказов =====
db.rebra.aggregate([
  { $match: { tip: "SERVES" } },
  { $group: { _id: "$ot", klientov: { $sum: 1 }, zakazov: { $sum: "$zakazov" } } },
  { $sort: { zakazov: -1 } }
])
