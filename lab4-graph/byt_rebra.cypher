// =====================================================================
// Лаба №4 (вариант 8): работа с рёбрами социального графа
// Выполнять ПОСЛЕ byt_social_graph.cypher (узлы уже созданы).
//   Шаг 4: удалить рёбра (узлы остаются)
//   Шаг 5: создать рёбра заново (MATCH по id + CREATE), 12 + 33 = 45
//   Шаг 6: подсчёт рёбер
//   Шаги 7-9: визуальный граф и выборки
// =====================================================================

// ---------- Шаг 4. Удаление рёбер ----------
MATCH ()-[r]->() DELETE r;

// Проверка: узлы на месте, рёбер нет
MATCH (n) RETURN n LIMIT 200;

// ---------- Шаг 5. Создание рёбер ----------
// принадлежность к группам (12)
MATCH (p:Persona {id: 1}), (g:Gruppa {id: 1}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 2}), (g:Gruppa {id: 1}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 3}), (g:Gruppa {id: 1}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 4}), (g:Gruppa {id: 1}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 5}), (g:Gruppa {id: 1}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 6}), (g:Gruppa {id: 2}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 7}), (g:Gruppa {id: 2}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 8}), (g:Gruppa {id: 2}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 9}), (g:Gruppa {id: 2}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 10}), (g:Gruppa {id: 2}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 11}), (g:Gruppa {id: 3}) CREATE (p)-[:BELONGS_TO]->(g);
MATCH (p:Persona {id: 12}), (g:Gruppa {id: 3}) CREATE (p)-[:BELONGS_TO]->(g);

// социальные связи (33)
MATCH (a:Persona {id: 1}), (b:Persona {id: 5}) CREATE (a)-[:FRIEND_OF {since: 2015, sila: 5}]->(b);
MATCH (a:Persona {id: 1}), (b:Persona {id: 3}) CREATE (a)-[:NEIGHBOR_OF {since: 2019, sila: 3}]->(b);
MATCH (a:Persona {id: 1}), (b:Persona {id: 4}) CREATE (a)-[:FRIEND_OF {since: 2021, sila: 3}]->(b);
MATCH (a:Persona {id: 2}), (b:Persona {id: 4}) CREATE (a)-[:FAMILY_OF {since: 1984, sila: 5, rodstvo: "сестра"}]->(b);
MATCH (a:Persona {id: 1}), (b:Persona {id: 2}) CREATE (a)-[:RECOMMENDED {data: date("2024-03-10")}]->(b);
MATCH (a:Persona {id: 2}), (b:Persona {id: 4}) CREATE (a)-[:RECOMMENDED {data: date("2025-06-02")}]->(b);
MATCH (a:Persona {id: 5}), (b:Persona {id: 3}) CREATE (a)-[:RECOMMENDED {data: date("2024-11-20")}]->(b);
MATCH (a:Persona {id: 5}), (b:Persona {id: 3}) CREATE (a)-[:FRIEND_OF {since: 2018, sila: 2}]->(b);
MATCH (a:Persona {id: 6}), (b:Persona {id: 1}) CREATE (a)-[:SERVES {zakazov: 7, poslednyaya_data: date("2026-10-03")}]->(b);
MATCH (a:Persona {id: 7}), (b:Persona {id: 1}) CREATE (a)-[:SERVES {zakazov: 5, poslednyaya_data: date("2026-10-03")}]->(b);
MATCH (a:Persona {id: 6}), (b:Persona {id: 3}) CREATE (a)-[:SERVES {zakazov: 4, poslednyaya_data: date("2026-10-02")}]->(b);
MATCH (a:Persona {id: 8}), (b:Persona {id: 4}) CREATE (a)-[:SERVES {zakazov: 2, poslednyaya_data: date("2026-10-12")}]->(b);
MATCH (a:Persona {id: 10}), (b:Persona {id: 2}) CREATE (a)-[:SERVES {zakazov: 3, poslednyaya_data: date("2026-10-15")}]->(b);
MATCH (a:Persona {id: 6}), (b:Persona {id: 5}) CREATE (a)-[:SERVES {zakazov: 20, poslednyaya_data: date("2026-10-14")}]->(b);
MATCH (a:Persona {id: 8}), (b:Persona {id: 5}) CREATE (a)-[:SERVES {zakazov: 18, poslednyaya_data: date("2026-10-14")}]->(b);
MATCH (a:Persona {id: 7}), (b:Persona {id: 3}) CREATE (a)-[:SERVES {zakazov: 3, poslednyaya_data: date("2026-09-20")}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 6}) CREATE (a)-[:MANAGES {since: 2022}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 7}) CREATE (a)-[:MANAGES {since: 2021}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 8}) CREATE (a)-[:MANAGES {since: 2022}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 10}) CREATE (a)-[:MANAGES {since: 2021}]->(b);
MATCH (a:Persona {id: 7}), (b:Persona {id: 6}) CREATE (a)-[:COLLEAGUE_OF {since: 2022, sila: 4}]->(b);
MATCH (a:Persona {id: 7}), (b:Persona {id: 8}) CREATE (a)-[:COLLEAGUE_OF {since: 2022, sila: 3}]->(b);
MATCH (a:Persona {id: 7}), (b:Persona {id: 10}) CREATE (a)-[:COLLEAGUE_OF {since: 2021, sila: 4}]->(b);
MATCH (a:Persona {id: 8}), (b:Persona {id: 10}) CREATE (a)-[:COLLEAGUE_OF {since: 2022, sila: 3}]->(b);
MATCH (a:Persona {id: 6}), (b:Persona {id: 8}) CREATE (a)-[:COLLEAGUE_OF {since: 2022, sila: 4}]->(b);
MATCH (a:Persona {id: 6}), (b:Persona {id: 1}) CREATE (a)-[:FRIEND_OF {since: 2023, sila: 3}]->(b);
MATCH (a:Persona {id: 10}), (b:Persona {id: 2}) CREATE (a)-[:FRIEND_OF {since: 2020, sila: 5}]->(b);
MATCH (a:Persona {id: 11}), (b:Persona {id: 7}) CREATE (a)-[:SUPPLIES {predmet: "фурнитура", chastota: "раз в неделю"}]->(b);
MATCH (a:Persona {id: 11}), (b:Persona {id: 8}) CREATE (a)-[:SUPPLIES {predmet: "ткани и нитки", chastota: "раз в 2 недели"}]->(b);
MATCH (a:Persona {id: 11}), (b:Persona {id: 10}) CREATE (a)-[:SUPPLIES {predmet: "запчасти", chastota: "раз в месяц"}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 11}) CREATE (a)-[:NEGOTIATES_WITH {since: 2022, dogovor: "поставка фурнитуры"}]->(b);
MATCH (a:Persona {id: 9}), (b:Persona {id: 12}) CREATE (a)-[:NEGOTIATES_WITH {since: 2024, dogovor: "доставка заказов"}]->(b);
MATCH (a:Persona {id: 12}), (b:Persona {id: 2}) CREATE (a)-[:DELIVERS_TO {zakazov: 6}]->(b);

// ---------- Шаг 6. Подсчёт рёбер (должно быть 45) ----------
MATCH ()-[r]->() RETURN count(r) AS vsego_reber;
MATCH ()-[r]->() RETURN type(r) AS tip, count(*) AS kolvo ORDER BY kolvo DESC;

// ---------- Шаг 7. Визуальный граф ----------
MATCH (n)-[r]->(m) RETURN n, r, m;

// ---------- Шаг 8. Связи между людьми ----------
MATCH (p:Persona)-[r:FRIEND_OF|FAMILY_OF|NEIGHBOR_OF|COLLEAGUE_OF|RECOMMENDED]->(q:Persona)
RETURN p, r, q;

// ---------- Шаг 9. Выборка по обработке заказов (аналог «музыкальных предпочтений») ----------
MATCH (s:Sotrudnik)-[r:SERVES]->(k:Klient) RETURN s, r, k;
