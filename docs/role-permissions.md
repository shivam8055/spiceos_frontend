# SpiceOS Frontend Role Access

The frontend uses the backend role values `owner`, `manager`, and `staff`.

| Route | Owner | Manager | Staff |
| --- | --- | --- | --- |
| `/` | Yes | Yes | Yes |
| `/orders` | Yes | Yes | Yes |
| `/orders/new` | Yes | Yes | Yes |
| `/customers` | Yes | Yes | Yes |
| `/inventory` | Yes | Yes | Yes |
| `/kitchen` | Yes | Yes | Yes |
| `/delivery` | Yes | Yes | No |
| `/reports` | Yes | Yes | No |
| `/settings` | Yes | No | No |

This is a frontend navigation guard only. Backend authorization remains authoritative and must reject unauthorized API requests with the appropriate HTTP status.
