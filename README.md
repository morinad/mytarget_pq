# Кастомный коннектор к MyTarget для Power BI

### Все коннекторы и поддержка:
В рамках подписки "ПРО" на Boosty https://boosty.to/morinad вы получите:
1) Все коннекторы mez для Power BI. 
2) Поддержку и ответы на вопросы.
3) Полезные наработки, скрипты и файлы.

### Наши курсы по Power Query, Power BI и автоматизации:
1) Основы Power BI (бесплатный курс): https://directprorf.ru/basics?utm_source=github
2) Power BI для рекламных отчётов: https://directprorf.ru/powerbi?utm_source=github
3) Из API в Excel и Power BI + коннекторы: https://directprorf.ru/excel?utm_source=github
4) Коннекторы для Маркетплейсов: https://directprorf.ru/marketplaces?utm_source=github
5) Продвинутый Power Query: https://directprorf.ru/pro?utm_source=github
6) Создание коннекторов в Power Query: https://directprorf.ru/connectors?utm_source=github
7) API ChatGPT для автоматизации бизнеса: https://directprorf.ru/chatgpt?utm_source=github

### Как воспользоваться коннектором:

1) Скачайте файлsы MEZ: https://github.com/morinad/mytarget_pq/raw/master/GetTokenMT.mez и https://github.com/morinad/mytarget_pq/raw/master/MyTarget.mez.
2) Перенесите файлы в папку C:\Users\USERNAME\Documents\Power BI Desktop\Custom Connectors, подставив USERNAME своего компьютера.
3) Откройте Power BI, зайдите в Файл -> Параметры и настройки -> Параметры -> Глобальные -> Безопасность, выберите "Разрешить загрузку любого расширения без проверок и предупреждений".
4) Перезапустите Power BI. Нажмите на кнопку "Получить данные", в поиске введите "MT" и выберите коннектор GetTokenMT Connector. 
5) Укажите свои client_id и client_secret (можно получить в поддержке mytarget) и произведите получение токена.
6) Запишите access_token и refresh_token, чтобы в дальнейшем иметь возможность их использовать.
7) Нажмите на кнопку "Получить данные", в поиске введите "MyTarget" и выберите коннектор MyTarget Connector. 


### Полезные ссылки:
Подробное видео по использованию коннектора: https://youtu.be/8PglMDYWXIo

Получение токена: https://target.my.com/help/advertisers/api_access/ru

