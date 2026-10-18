// =====================================================================
// Лабораторная №4. Социальный граф персонажей. Вариант 8: служба быта
// СУБД: Neo4j (Neo4j Browser / AuraDB Free), язык Cypher
//
// Структура графа
//   Узлы:  (:Gruppa)   — группа пользователей (клиенты / сотрудники / партнёры)
//          (:Persona)  — конкретный персонаж; вторая метка = группа
//                        (:Klient, :Sotrudnik, :Partner)
//   Рёбра: BELONGS_TO       Persona -> Gruppa
//          FRIEND_OF        друзья                  (симметричная)
//          FAMILY_OF        родственники            (симметричная)
//          NEIGHBOR_OF      соседи                  (симметричная)
//          COLLEAGUE_OF     коллеги по работе       (симметричная)
//          RECOMMENDED      рекомендовал службу     (направленная)
//          SERVES           сотрудник обслуживает клиента (направленная)
//          MANAGES          руководит               (направленная)
//          SUPPLIES         поставляет материалы    (направленная)
//          DELIVERS_TO      доставляет заказы       (направленная)
//          NEGOTIATES_WITH  ведёт переговоры        (симметричная)
//   Симметричные связи хранятся одним ребром; в запросах
//   они читаются без стрелки: (a)-[:FRIEND_OF]-(b).
//
// Итого: 15 узлов (3 группы + 12 персонажей), 12 рёбер BELONGS_TO
//        и 33 социальных ребра = 45 рёбер.
// =====================================================================

// ---- 0. Очистка (скрипт можно запускать повторно) --------------------
MATCH (n) DETACH DELETE n;

// ---- 1. Ограничения уникальности -------------------------------------
CREATE CONSTRAINT persona_id IF NOT EXISTS FOR (p:Persona) REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT gruppa_id  IF NOT EXISTS FOR (g:Gruppa)  REQUIRE g.id IS UNIQUE;

// ---- 2. Узлы и рёбра одним запросом ----------------------------------
CREATE
// ===== Группы пользователей (уникальный признак — роль в процессе заказа) =====
(gK:Gruppa {id: 1, nazvanie: "Клиенты",    opisanie: "Конечные потребители услуг",
            pervichnaya_tsel: "Быстро и недорого решить бытовую проблему"}),
(gS:Gruppa {id: 2, nazvanie: "Сотрудники", opisanie: "Принимают заказы и выполняют работы",
            pervichnaya_tsel: "Обработать заказ в срок и без ошибок"}),
(gP:Gruppa {id: 3, nazvanie: "Партнёры",   opisanie: "Поставщики и логистика",
            pervichnaya_tsel: "Регулярные договорные поставки и доставка"}),

// ===== Персонажи-клиенты =====
(pavel:Persona:Klient {id: 1, imya: "Павел", familiya: "Петров", vozrast: 34, gorod: "Рига",
   obrazovanie: "высшее", foto: "petrov.jpg",
   biografiya: "Менеджер по продажам, живёт один, ценит своё время",
   opyt: "Пользуется службой 3 года, около 12 заказов", gotovnost: "высокая",
   tseli: "Сдать вещи рядом с домом и забрать в срок"}),
(elena:Persona:Klient {id: 2, imya: "Елена", familiya: "Кузнецова", vozrast: 42, gorod: "Рига",
   obrazovanie: "высшее", foto: "kuznetsova.jpg",
   biografiya: "Мать двоих детей, много вещей в химчистку и ремонт",
   opyt: "Постоянный клиент, 8 заказов", gotovnost: "высокая",
   tseli: "Сэкономить время семьи, чтобы заказ был принят одним визитом"}),
(andris:Persona:Klient {id: 3, imya: "Андрис", familiya: "Лиепа", vozrast: 67, gorod: "Рига",
   obrazovanie: "среднее специальное", foto: "liepa.jpg",
   biografiya: "Пенсионер, не пользуется онлайн-сервисами",
   opyt: "Заказывает ключи и ремонт обуви раз в полгода", gotovnost: "средняя",
   tseli: "Доверить мелкий ремонт знакомому мастеру"}),
(olga:Persona:Klient {id: 4, imya: "Ольга", familiya: "Новикова", vozrast: 29, gorod: "Рига",
   obrazovanie: "высшее", foto: "novikova.jpg",
   biografiya: "Дизайнер, работает удалённо, следит за модой",
   opyt: "Новый клиент, 2 заказа", gotovnost: "средняя",
   tseli: "Подогнать одежду и узнать срок заказа без звонков"}),
(dmitry:Persona:Klient {id: 5, imya: "Дмитрий", familiya: "Орлов", vozrast: 45, gorod: "Рига",
   obrazovanie: "высшее", foto: "orlov.jpg",
   biografiya: "Владелец небольшого кафе, отдаёт форму персонала в стирку",
   opyt: "Корпоративный клиент, еженедельные заказы", gotovnost: "очень высокая",
   tseli: "Стабильные сроки и скидка на объём"}),

// ===== Персонажи-сотрудники =====
(anna:Persona:Sotrudnik {id: 6, imya: "Анна", familiya: "Иванова", vozrast: 31, gorod: "Рига",
   obrazovanie: "среднее специальное", foto: "ivanova.jpg", dolzhnost: "Приёмщик",
   biografiya: "В службе с 2022 года, общительная",
   opyt: "Принимает до 25 заказов в день", gotovnost: "не применимо",
   tseli: "Оформить заказ без ошибок и сразу назвать срок"}),
(oleg:Persona:Sotrudnik {id: 7, imya: "Олег", familiya: "Сидоров", vozrast: 48, gorod: "Рига",
   obrazovanie: "среднее специальное", foto: "sidorov.jpg", dolzhnost: "Мастер по обуви",
   biografiya: "Мастер с 20-летним стажем",
   opyt: "Выполняет около 15 работ в день", gotovnost: "не применимо",
   tseli: "Получать понятные заказы с указанием дефекта"}),
(irina:Persona:Sotrudnik {id: 8, imya: "Ирина", familiya: "Крылова", vozrast: 38, gorod: "Юрмала",
   obrazovanie: "среднее специальное", foto: "krylova.jpg", dolzhnost: "Портной",
   biografiya: "Шьёт и подгоняет одежду, принимает корпоративные заказы",
   opyt: "В службе с 2022 года", gotovnost: "не применимо",
   tseli: "Видеть очередь работ и срочные заказы"}),
(natalya:Persona:Sotrudnik {id: 9, imya: "Наталья", familiya: "Попова", vozrast: 44, gorod: "Рига",
   obrazovanie: "высшее", foto: "popova.jpg", dolzhnost: "Администратор",
   biografiya: "Руководит пунктом приёма, отвечает за сроки и жалобы",
   opyt: "Работает с 2021 года", gotovnost: "не применимо",
   tseli: "Контролировать статусы заказов и загрузку мастеров"}),
(mihail:Persona:Sotrudnik {id: 10, imya: "Михаил", familiya: "Громов", vozrast: 52, gorod: "Рига",
   obrazovanie: "среднее специальное", foto: "gromov.jpg", dolzhnost: "Мастер по технике",
   biografiya: "Ремонтирует мелкую бытовую технику",
   opyt: "Работает с 2020 года", gotovnost: "не применимо",
   tseli: "Вовремя получать запчасти и заказы"}),

// ===== Персонажи-партнёры =====
(janis:Persona:Partner {id: 11, imya: "Янис", familiya: "Берзиньш", vozrast: 40, gorod: "Рига",
   obrazovanie: "высшее", foto: "berzins.jpg", organizatsiya: "SIA Furnitura",
   biografiya: "Владелец оптовой компании по поставке фурнитуры и запчастей",
   opyt: "Сотрудничает со службой 4 года", gotovnost: "высокая",
   tseli: "Крупные регулярные заказы по договору"}),
(artem:Persona:Partner {id: 12, imya: "Артём", familiya: "Соколов", vozrast: 36, gorod: "Рига",
   obrazovanie: "среднее специальное", foto: "sokolov.jpg", organizatsiya: "ИП Соколов, курьер",
   biografiya: "Возит заказы клиентам, которые не могут прийти сами",
   opyt: "Сотрудничает со службой 2 года", gotovnost: "высокая",
   tseli: "Плотный маршрут и предсказуемое расписание"}),

// ===== Рёбра BELONGS_TO (12) =====
(pavel)-[:BELONGS_TO]->(gK),   (elena)-[:BELONGS_TO]->(gK),   (andris)-[:BELONGS_TO]->(gK),
(olga)-[:BELONGS_TO]->(gK),    (dmitry)-[:BELONGS_TO]->(gK),
(anna)-[:BELONGS_TO]->(gS),    (oleg)-[:BELONGS_TO]->(gS),    (irina)-[:BELONGS_TO]->(gS),
(natalya)-[:BELONGS_TO]->(gS), (mihail)-[:BELONGS_TO]->(gS),
(janis)-[:BELONGS_TO]->(gP),   (artem)-[:BELONGS_TO]->(gP),

// ===== Связи клиент — клиент (8) =====
(pavel)-[:FRIEND_OF   {since: 2015, sila: 5}]->(dmitry),
(pavel)-[:NEIGHBOR_OF {since: 2019, sila: 3}]->(andris),
(pavel)-[:FRIEND_OF   {since: 2021, sila: 3}]->(olga),
(elena)-[:FAMILY_OF   {since: 1984, sila: 5, rodstvo: "сестра"}]->(olga),
(pavel)-[:RECOMMENDED {data: date("2024-03-10")}]->(elena),
(elena)-[:RECOMMENDED {data: date("2025-06-02")}]->(olga),
(dmitry)-[:RECOMMENDED {data: date("2024-11-20")}]->(andris),
(dmitry)-[:FRIEND_OF  {since: 2018, sila: 2}]->(andris),

// ===== Связи сотрудник — клиент SERVES (8) =====
(anna)-[:SERVES {zakazov: 7, poslednyaya_data: date("2026-10-03")}]->(pavel),
(oleg)-[:SERVES {zakazov: 5, poslednyaya_data: date("2026-10-03")}]->(pavel),
(anna)-[:SERVES {zakazov: 4, poslednyaya_data: date("2026-10-02")}]->(andris),
(irina)-[:SERVES {zakazov: 2, poslednyaya_data: date("2026-10-12")}]->(olga),
(mihail)-[:SERVES {zakazov: 3, poslednyaya_data: date("2026-10-15")}]->(elena),
(anna)-[:SERVES {zakazov: 20, poslednyaya_data: date("2026-10-14")}]->(dmitry),
(irina)-[:SERVES {zakazov: 18, poslednyaya_data: date("2026-10-14")}]->(dmitry),
(oleg)-[:SERVES {zakazov: 3, poslednyaya_data: date("2026-09-20")}]->(andris),

// ===== Связи сотрудник — сотрудник (11) =====
(natalya)-[:MANAGES {since: 2022}]->(anna),
(natalya)-[:MANAGES {since: 2021}]->(oleg),
(natalya)-[:MANAGES {since: 2022}]->(irina),
(natalya)-[:MANAGES {since: 2021}]->(mihail),
(oleg)-[:COLLEAGUE_OF   {since: 2022, sila: 4}]->(anna),
(oleg)-[:COLLEAGUE_OF   {since: 2022, sila: 3}]->(irina),
(oleg)-[:COLLEAGUE_OF   {since: 2021, sila: 4}]->(mihail),
(irina)-[:COLLEAGUE_OF  {since: 2022, sila: 3}]->(mihail),
(anna)-[:COLLEAGUE_OF   {since: 2022, sila: 4}]->(irina),
(anna)-[:FRIEND_OF      {since: 2023, sila: 3}]->(pavel),
(mihail)-[:FRIEND_OF    {since: 2020, sila: 5}]->(elena),

// ===== Связи с партнёрами (6) =====
(janis)-[:SUPPLIES {predmet: "фурнитура", chastota: "раз в неделю"}]->(oleg),
(janis)-[:SUPPLIES {predmet: "ткани и нитки", chastota: "раз в 2 недели"}]->(irina),
(janis)-[:SUPPLIES {predmet: "запчасти", chastota: "раз в месяц"}]->(mihail),
(natalya)-[:NEGOTIATES_WITH {since: 2022, dogovor: "поставка фурнитуры"}]->(janis),
(natalya)-[:NEGOTIATES_WITH {since: 2024, dogovor: "доставка заказов"}]->(artem),
(artem)-[:DELIVERS_TO {zakazov: 6}]->(elena);

// ---- 3. Проверки и запросы для скриншотов -----------------------------

// 3.1 Весь граф (скрин графа)
MATCH (n)-[r]->(m) RETURN n, r, m;

// 3.2 Количество узлов и рёбер (должно быть 15 и 45)
MATCH (n) RETURN count(n) AS uzly;
MATCH ()-[r]->() RETURN count(r) AS rebra;

// 3.3 Рёбра по типам
MATCH ()-[r]->() RETURN type(r) AS tip_rebra, count(*) AS kolichestvo ORDER BY kolichestvo DESC;

// 3.4 Узлы по группам
MATCH (p:Persona)-[:BELONGS_TO]->(g:Gruppa)
RETURN g.nazvanie AS gruppa, count(p) AS person, collect(p.imya + " " + p.familiya) AS imena;

// 3.5 Кто рекомендовал службу Ольге (цепочка рекомендаций)
MATCH path = (a:Klient)-[:RECOMMENDED*1..3]->(o:Klient {familiya: "Новикова"})
RETURN path;

// 3.6 Самый загруженный сотрудник (по числу обслуженных клиентов)
MATCH (s:Sotrudnik)-[r:SERVES]->(k:Klient)
RETURN s.imya + " " + s.familiya AS sotrudnik, count(DISTINCT k) AS klientov, sum(r.zakazov) AS zakazov
ORDER BY zakazov DESC;
