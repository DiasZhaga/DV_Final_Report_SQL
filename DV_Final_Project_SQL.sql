-- Задание 1: Список клиентов с непрерывной историей за год
WITH Monthly_Transactions AS (
    SELECT
        ID_client,
        DATE_FORMAT(date_new, '%Y-%m') AS month,
        COUNT(DISTINCT Id_check) AS monthly_transactions,
        SUM(Sum_payment) AS total_monthly_sum,
        AVG(Sum_payment) AS avg_monthly_check
    FROM
        transactions_info
    WHERE
        date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY
        ID_client, month
),
Client_History AS (
    SELECT
        ID_client,
        COUNT(DISTINCT month) AS active_months,
        AVG(total_monthly_sum) AS avg_monthly_purchase,
        AVG(avg_monthly_check) AS avg_check,
        SUM(monthly_transactions) AS total_transactions
    FROM
        Monthly_Transactions
    GROUP BY
        ID_client
    HAVING
        active_months = 13  
)
SELECT
    c.Id_client,
    c.Total_amount,
    ch.avg_check AS average_check_per_period,
    ch.avg_monthly_purchase AS average_monthly_purchase,
    ch.total_transactions AS total_operations
FROM
    Client_History ch
JOIN
    customer_info c ON ch.ID_client = c.Id_client;

-- Задание 2: Информация в разрезе месяцев
-- a) Средняя сумма чека в месяц
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS avg_check
FROM
    transactions_info
GROUP BY
    month
ORDER BY
    month;

-- b) Среднее количество операций в месяц
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) / COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) AS avg_operations
FROM
    transactions_info
GROUP BY
    month
ORDER BY
    month;

-- c) Среднее количество клиентов, которые совершали операции
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(DISTINCT ID_client) AS avg_clients
FROM
    transactions_info
GROUP BY
    month
ORDER BY
    month;

-- d) Доля от общего количества операций за год
-- 1. Доля от общего количества операций
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    COUNT(Id_check) AS total_operations,
    (COUNT(Id_check) / (SELECT COUNT(*) FROM transactions_info WHERE DATE_FORMAT(date_new, '%Y') = '2015')) * 100 AS percentage_of_year
FROM
    transactions_info
WHERE
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- 2. Доля в месяц от общей суммы операций
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    SUM(Sum_payment) AS total_sum,
    (SUM(Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions_info WHERE DATE_FORMAT(date_new, '%Y') = '2015')) * 100 AS percentage_of_month
FROM
    transactions_info
WHERE
    date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- e) Вывести % соотношение M/F/NA в каждом месяце с их долей затрат
SELECT
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) AS male_spending,
    SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) AS female_spending,
    SUM(CASE WHEN c.Gender IS NULL THEN t.Sum_payment ELSE 0 END) AS na_spending,
    (SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100 AS male_percentage,
    (SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100 AS female_percentage,
    (SUM(CASE WHEN c.Gender IS NULL THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100 AS na_percentage
FROM
    transactions_info t
JOIN
    customer_info c ON t.ID_client = c.Id_client
WHERE
    t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
    month
ORDER BY
    month;

-- Задание 3: Возрастные группы клиентов
-- Возрастные группы клиентов
SELECT
    CASE
        WHEN Age < 10 THEN '0-9'
        WHEN Age < 20 THEN '10-19'
        WHEN Age < 30 THEN '20-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        WHEN Age < 70 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    SUM(t.Sum_payment) AS total_spending,
    COUNT(t.Id_check) AS total_transactions
FROM
    customer_info c
JOIN
    transactions_info t ON c.Id_client = t.ID_client
GROUP BY
    age_group
ORDER BY
    age_group;

-- Клиенты без информации о возрасте
SELECT
    'No Age Info' AS age_group,
    SUM(t.Sum_payment) AS total_spending,
    COUNT(t.Id_check) AS total_transactions
FROM
    customer_info c
JOIN
    transactions_info t ON c.Id_client = t.ID_client
WHERE
    c.Age IS NULL;

-- Поквартальная статистика
SELECT
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
    AVG(t.Sum_payment) AS avg_transaction_value,
    COUNT(t.Id_check) AS total_transactions,
    COUNT(DISTINCT t.ID_client) AS total_clients
FROM
    transactions_info t
JOIN
    customer_info c ON t.ID_client = c.Id_client
GROUP BY
    quarter
ORDER BY
    quarter;
