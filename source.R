library(httr)
library(purrr)
library(lubridate)


## Wolt 
wolt_cookies = c(
  '_ga' = Sys.getenv("_GA"),
  'ravelinSessionId' = '7a903b08-6a83-4134-be14-206e1ab0abb0',
  'ravelinDeviceId' = Sys.getenv("RAVELIN_DEVICE_ID"),
  '_gcl_au' =  Sys.getenv("_GCL_AU"),
  'rskxRunCookie' = '0',
  'rCookie' = Sys.getenv("WOLT_RCOOKIE"),
  'cwc-consents' = '{%22functional%22:false%2C%22analytics%22:false%2C%22marketing%22:false}',
  'lastRskxRun' = '1649158149910',
  'intercom-id-qwum5ehb' = Sys.getenv("INTERCOM_ID"),
  'intercom-session-qwum5ehb' = ''
)

wolt_headers = c(
  `authority` = 'restaurant-api.wolt.com',
  `accept` = 'application/json, text/plain, */*',
  `accept-language` = 'en-FI,en;q=0.9,es-ES;q=0.8,es;q=0.7,en-US;q=0.6',
  `app-language` = 'en',
  `clientversionnumber` = '1.7.12',
  `dnt` = '1',
  `origin` = 'https://wolt.com',
  `platform` = 'Web',
  `referer` = 'https://wolt.com/',
  `sec-ch-ua` = '"Chromium";v="100", " Not A;Brand";v="99"',
  `sec-ch-ua-mobile` = '?1',
  `sec-ch-ua-platform` = '"Android"',
  `sec-fetch-dest` = 'empty',
  `sec-fetch-mode` = 'cors',
  `sec-fetch-site` = 'same-site',
  `user-agent` = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.147 Mobile Safari/537.36',
  `x-wolt-web-clientid` = 'ecce9731b1c1b629f2965f614553b458'
)

wolt_params = list(
  `lat` = '61.12612319999999',
  `lon` = '21.4936977'
)

wolt_res <- httr::GET(url = 'https://restaurant-api.wolt.com/v1/pages/restaurants', httr::add_headers(.headers=wolt_headers), query = wolt_params, httr::set_cookies(.cookies = wolt_cookies))

wolt_content <- content(wolt_res)

wolt_list <- map(wolt_content$sections[[1]]$items,"venue")

wolt_data <- data.frame(name = map_chr(wolt_list,"name"),
       address = map_chr(wolt_list,"address"),
       delivery_price = map_chr(wolt_list,"delivery_price"),
       estimate = map_chr(wolt_list,"estimate"),
       online = map_chr(wolt_list,"online"),
       time_retreived = lubridate::floor_date(Sys.time(),"hour"))

write.table(wolt_data, file = "output/wolt_data.csv",
            sep = ",", row.names = FALSE,
            append = TRUE,fileEncoding = "UTF-8")


##Foodora##
headers_foodora = c(
  `authority` = 'disco.deliveryhero.io',
  `accept` = 'application/json, text/plain, */*',
  `accept-language` = 'en-FI,en;q=0.9,es-ES;q=0.8,es;q=0.7,en-US;q=0.6',
  `dnt` = '1',
  `dps-session-id` = Sys.getenv("FOODORA_DPS_SESSION_ID"),
  `origin` = 'https://www.foodora.fi',
  `referer` = 'https://www.foodora.fi/',
  `sec-ch-ua` = '"Chromium";v="100", " Not A;Brand";v="99"',
  `sec-ch-ua-mobile` = '?1',
  `sec-ch-ua-platform` = '"Android"',
  `sec-fetch-dest` = 'empty',
  `sec-fetch-mode` = 'cors',
  `sec-fetch-site` = 'cross-site',
  `user-agent` = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.147 Mobile Safari/537.36',
  `x-disco-client-id` = 'web',
  `x-fp-api-key` = 'volo'
)

params_foodora = list(
  `latitude` = '61.12593151076399',
  `longitude` = '21.493923005557264',
  `language_id` = '4',
  `include` = 'characteristics',
  `dynamic_pricing` = '0',
  `configuration` = 'vendor-ranking-Variation-Variation1',
  `country` = 'po',
  `customer_id` = '',
  `customer_hash` = '',
  `budgets` = '',
  `cuisine` = '',
  `sort` = '',
  `payment_type` = '',
  `food_characteristic` = '',
  `use_free_delivery_label` = 'true',
  `tag_label_metadata` = 'false',
  `ncr_screen` = 'shop_list',
  `ncr_place` = 'list',
  `vertical` = 'restaurants',
  `limit` = '100',
  `offset` = '0',
  `customer_type` = 'regular'
)

res_foodora <- httr::GET(url = 'https://disco.deliveryhero.io/listing/api/v1/pandora/vendors', httr::add_headers(.headers=headers_foodora), query = params_foodora)

content_foodora <- content(res_foodora)$data$items

foodora_data <- data.frame(name =map_chr(content_foodora,"name"),
                           address = map_chr(content_foodora,"address"),
                           delivery_price = map_chr(content_foodora,"minimum_delivery_fee"),
                           estimate = map_chr(content_foodora,"minimum_delivery_time"),
                           online = map_chr(content_foodora,"is_active"),
                           time_retreived = lubridate::floor_date(Sys.time(),"hour"))

write.table(foodora_data, file = "output/foodora_data.csv",
            sep = ",", row.names = FALSE,
            append = TRUE,fileEncoding = "UTF-8")
