//  БД: byt_zakazy — запросы к данным (вариант 8)
//  Выполнять после byt_zakazy.js, по блокам, в MONGOSH внутри Compass.

use("byt_zakazy")

// ===== 9. Поиск услуг по категории (категория 2 — Химчистка) =====
db.usluga.find({ kategoriya_id: 2 }).pretty()

// ===== 10. Добавление новых услуг =====
db.usluga.insertMany([
  { _id: 11, nazvanie: "Химчистка шубы",        kategoriya_id: 2, tsena: 45.00, srok_dney: 5 },
  { _id: 12, nazvanie: "Химчистка свадебного платья", kategoriya_id: 2, tsena: 60.00, srok_dney: 7 },
  { _id: 13, nazvanie: "Химчистка ковра",       kategoriya_id: 2, tsena: 30.00, srok_dney: 4 },
  { _id: 14, nazvanie: "Химчистка пледа",       kategoriya_id: 2, tsena: 12.00, srok_dney: 2 }
])

// ===== 11. Добавление заказов на новые услуги =====
var maxZ = db.zakaz.find().sort({ _id: -1 }).limit(1).toArray()[0]._id

var uShuba  = db.usluga.findOne({ nazvanie: "Химчистка шубы" })._id
var uPlatye = db.usluga.findOne({ nazvanie: "Химчистка свадебного платья" })._id
var uKovyor = db.usluga.findOne({ nazvanie: "Химчистка ковра" })._id
var uPled   = db.usluga.findOne({ nazvanie: "Химчистка пледа" })._id

db.zakaz.insertMany([
  { _id: maxZ + 1, nomer_zakaza: "ZK-2026-011", klient_id: 1, punkt_id: 1, priemshchik_id: 3, status_id: 1,
    data_sozdaniya: new Date(), plan_data: new Date(Date.now() + 5*86400000), fakt_data: null, primechanie: "Шуба",
    pozitsii: [ { nomer: 1, usluga_id: uShuba, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 45.00 } ],
    istoriya: [ { status_id: 1, data: new Date(), sotrudnik_id: 3 } ] },
  { _id: maxZ + 2, nomer_zakaza: "ZK-2026-012", klient_id: 2, punkt_id: 2, priemshchik_id: 4, status_id: 2,
    data_sozdaniya: new Date(), plan_data: new Date(Date.now() + 7*86400000), fakt_data: null, primechanie: "В работе",
    pozitsii: [ { nomer: 1, usluga_id: uPlatye, ispolnitel_id: 6, kolichestvo: 1, tsena_fiks: 60.00 } ],
    istoriya: [ { status_id: 1, data: new Date(), sotrudnik_id: 4 }, { status_id: 2, data: new Date(), sotrudnik_id: 6 } ] },
  { _id: maxZ + 3, nomer_zakaza: "ZK-2026-013", klient_id: 3, punkt_id: 1, priemshchik_id: 3, status_id: 1,
    data_sozdaniya: new Date(), plan_data: new Date(Date.now() + 4*86400000), fakt_data: null, primechanie: null,
    pozitsii: [ { nomer: 1, usluga_id: uKovyor, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 30.00 } ],
    istoriya: [ { status_id: 1, data: new Date(), sotrudnik_id: 3 } ] },
  { _id: maxZ + 4, nomer_zakaza: "ZK-2026-014", klient_id: 4, punkt_id: 3, priemshchik_id: 9, status_id: 5,
    data_sozdaniya: new Date(), plan_data: new Date(Date.now() + 2*86400000), fakt_data: null, primechanie: "Отменён клиентом",
    pozitsii: [ { nomer: 1, usluga_id: uPled, ispolnitel_id: null, kolichestvo: 1, tsena_fiks: 12.00 } ],
    istoriya: [ { status_id: 1, data: new Date(), sotrudnik_id: 9 }, { status_id: 5, data: new Date(), sotrudnik_id: 9 } ] }
])

// ===== 12. Все заказы с датой создания и статусом (с названием через $lookup) =====
db.zakaz.aggregate([
  { $lookup: { from: "status_zakaza", localField: "status_id", foreignField: "_id", as: "status" } },
  { $unwind: "$status" },
  { $project: { _id: 0, nomer_zakaza: 1, data_sozdaniya: 1, plan_data: 1, status: "$status.nazvanie" } },
  { $sort: { data_sozdaniya: 1 } }
])

// ===== 13. Общее количество услуг категории и заказов =====
print("Услуг в категории «Химчистка»: " + db.usluga.countDocuments({ kategoriya_id: 2 }))
print("Всего заказов: " + db.zakaz.countDocuments())
print("Заказов со статусом «Принят»: " + db.zakaz.countDocuments({ status_id: 1 }))

// Сумма каждого заказа (аналог представления v_order_total из PostgreSQL)
db.zakaz.aggregate([
  { $project: { _id: 0, nomer_zakaza: 1,
      summa: { $sum: { $map: { input: "$pozitsii", as: "p", in: { $multiply: ["$$p.kolichestvo", "$$p.tsena_fiks"] } } } } } }
])

// ===== 14. Удаление заказа по номеру =====
db.zakaz.deleteOne({ nomer_zakaza: "ZK-2026-014" })
db.zakaz.deleteOne({ nomer_zakaza: "ZK-2026-099" })   // несуществующий: deletedCount = 0
