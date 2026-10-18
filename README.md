# Лабораторные работы по базам данных — вариант 8

**Предметная область:** система описывает порядок обработки заказов в службе быта.

В репозитории четыре работы: реляционная модель 3NF, Data Vault, MongoDB и социальный граф в Neo4j.

## Структура

| Папка | Содержимое | СУБД / инструмент |
|---|---|---|
| `lab1-3nf/` | Схема 3NF: `byt_3nf_mysql.sql` (MySQL), `byt_3nf_postgres.sql` (PostgreSQL), диаграмма `byt_3nf_EER.png`, модель `byt_3nf.mwb` | MySQL 8 / Workbench |
| `lab2-datavault/` | Data Vault: `byt_dv_mysql.sql`, диаграмма `byt_dv_EER.png`, модель `byt_dv.mwb` | MySQL 8 / Workbench |
| `lab3-mongodb/` | `byt_zakazy.js` — создание БД и коллекций, `byt_zaprosy.js` — запросы | MongoDB, Compass / mongosh |
| `lab4-graph/` | `byt_social_graph.cypher` — граф в Neo4j, `byt_rebra.cypher` — пересоздание рёбер, `byt_graf_mongo.js` — тот же граф в MongoDB | Neo4j Desktop, MongoDB |

## Как загрузить

### Лаба 1 — 3NF (MySQL)
1. Откройте MySQL Workbench и подключитесь к локальному серверу.
2. File → Open SQL Script → `lab1-3nf/byt_3nf_mysql.sql`.
3. Нажмите молнию (Execute). Создастся схема `sluzhba_byta`: 12 таблиц, связи, комментарии и тестовые данные.

Для PostgreSQL используйте `byt_3nf_postgres.sql` (схема `byt`):
`psql -U postgres -f lab1-3nf/byt_3nf_postgres.sql`

### Лаба 2 — Data Vault (MySQL)
1. Откройте `lab2-datavault/byt_dv_mysql.sql` в Workbench с активным подключением.
2. Выполните скрипт. Создастся схема `sluzhba_byta_dv`: 9 хабов, 8 линков, 9 саттелитов (только структура).

### Лаба 3 — MongoDB
1. Запустите сервер MongoDB, подключитесь в Compass к `mongodb://localhost:27017`.
2. Откройте MONGOSH внизу окна, вставьте содержимое `lab3-mongodb/byt_zakazy.js`. Создастся база `byt_zakazy` (10 коллекций).
3. Запросы из `lab3-mongodb/byt_zaprosy.js` выполняйте по одному блоку.

Либо из терминала: `mongosh --file lab3-mongodb/byt_zakazy.js`

### Лаба 4 — социальный граф
**Neo4j Desktop:** откройте Query, вставьте содержимое `lab4-graph/byt_social_graph.cypher`.
Граф: 15 узлов (3 группы + 12 персонажей), 45 рёбер (12 принадлежностей к группе и 33 социальные связи).
Узлы: `Gruppa`, `Persona` (метки `Klient`, `Sotrudnik`, `Partner`).
Рёбра: `BELONGS_TO`, `FRIEND_OF`, `FAMILY_OF`, `NEIGHBOR_OF`, `COLLEAGUE_OF`, `RECOMMENDED`, `SERVES` и др.

`byt_rebra.cypher` удаляет все рёбра и создаёт их заново (шаги 4–9).

**MongoDB:** тот же граф в `lab4-graph/byt_graf_mongo.js` (коллекции `uzly`, `rebra`, запросы с `$graphLookup`).

## Автор
Вариант 8, студент: _(укажите ФИО и группу)_
