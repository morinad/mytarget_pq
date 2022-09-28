# Кастомный коннектор к MyTarget для Power BI

### Курсы для начинающих:
1) Основы Power BI: https://directprorf.ru/basics?utm_source=github
2) Из API -> в Excel и Power BI + коннекторы-функции: https://directprorf.ru/excel?utm_source=github

### Продвинутые курсы:
3) Продвинутый Power Query: https://directprorf.ru/pro?utm_source=github
4) Создание коннекторов в Power Query: https://directprorf.ru/connectors?utm_source=github

По всем вопросам, связанным с курсами и коннекторами: https://t.me/alexdirect или 8-916-978-77-46.

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

