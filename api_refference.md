FORMAT: 1A
HOST: https://api.gycwifi.com/

# WiFi

Описание API для тестового сервера.

Ко всем запросам, начиная со второй версии *(V2)*, все запросы содержат в себе два технических заголовка:
* JWT-токен с базовой информацией о пользователе
* Указание версии запроса **(V1/V2/V3/...)** в формате:
    * ключ: ```Accept```
    * значение: ```application/vnd.wifi.v1+json```, где **v1** это версия запроса

## Brands Collection [/brands]

### List All Brands [GET]

Список всех брендов *(шаблонов)*

+ Response 200 (application/json)

        [
            {
                "data": {
                    "brands": [
                        {
                            "id": 1,
                            "title": "Тестовая точка",
                            "logo": "/images/logo.png",
                            "bg_color": "#0e1a35",
                            "background": "/images/default_background.png",
                            "sms_auth": true,
                            "redirect_url": "https://gycwifi.com",
                            "auth_expiration_time": 3600,
                            "category_id": 17,
                            "promo_text": "Sample promo text",
                            "slug": "testovaya-tochka",
                            "user_id": 71,
                            "updated_at": "2017-02-20T16:05:30.814Z"
                        }
                    ],
                    "can_create": false,
                    "items_count": 117
                },
                "message": "Brands list",
                "status:" "ok"
            }
        ]

### Create [POST]

Создание бренда

+ Response 200 (application/json)

        [
            {
                "data": {
                    "brand": [
                        {
                            "id": 1,
                            "title": "Тестовая точка",
                            "logo": "/images/logo.png",
                            "bg_color": "#0e1a35",
                            "background": "/images/default_background.png",
                            "sms_auth": true,
                            "redirect_url": "https://gycwifi.com",
                            "auth_expiration_time": 3600,
                            "category_id": 17,
                            "promo_text": "Sample promo text",
                            "slug": "testovaya-tochka",
                            "user_id": 71,
                            "updated_at": "2017-02-20T16:05:30.814Z"
                        }
                    ],
                    "can_create": false,
                    "items_count": 117
                },
                "message": "Brands list",
                "status": "ok"
            }
        ]

## Brand by params [/brands/{slug}]

### Show [GET]

Данные по одному бренду, по параметрам

+ Parameters

    + slug: "testovaya_tochka" (string) - уникальный идентификатор бренда

+ Request JSON Message

    + Headers

            Accept: application/json

+ Response 200 (application/json)

        [
            {
                "data": {
                    "brand": [
                        {
                            "id": 1,
                            "title": "Тестовая точка",
                            "logo": "/images/logo.png",
                            "bg_color": "#0e1a35",
                            "background": "/images/default_background.png",
                            "sms_auth": true,
                            "redirect_url": "https://gycwifi.com",
                            "auth_expiration_time": 3600,
                            "category_id": 17,
                            "promo_text": "Sample promo text",
                            "slug": "testovaya-tochka",
                            "user_id": 71,
                            "updated_at": "2017-02-20T16:05:30.814Z"
                        }
                    ],
                },
                "message": "Brand",
                "status": "ok"
            }
        ]

### Update [PUT]

Обновление бренда

+ Parameters

    + slug: "testovaya_tochka" (string) - уникальный идентификатор бренда

+ Request JSON Message

    + Headers

            Accept: application/json

+ Response 200 (application/json)

        [
            {
                "data": {
                    "brand": [
                        {
                            "id": 1,
                            "title": "Тестовая точка",
                            "logo": "/images/logo.png",
                            "bg_color": "#0e1a35",
                            "background": "/images/default_background.png",
                            "sms_auth": true,
                            "redirect_url": "https://gycwifi.com",
                            "auth_expiration_time": 3600,
                            "category_id": 17,
                            "promo_text": "Sample promo text",
                            "slug": "testovaya-tochka",
                            "user_id": 71,
                            "updated_at": "2017-02-20T16:05:30.814Z"
                        }
                    ]
                },
                "message": "Brand updated",
                "status": "ok"
            }
        ]

### Destroy [DELETE]

Удаление бренда

+ Parameters

    + slug: "testovaya_tochka" (string) - уникальный идентификатор бренда

+ Request JSON Message

    + Headers

            Accept: application/json

+ Response 200 (application/json)

        [
            {
                "data": null,
                "message": "Brand deleted",
                "status": "ok"
            }
        ]
