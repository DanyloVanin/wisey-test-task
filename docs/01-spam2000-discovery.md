# spam2000 Container Discovery

Runtime investigation of `andriiuni/spam2000:1.1394.355`

## Container Details

| Property | Value |
|----------|-------|
| **Image** | `andriiuni/spam2000:1.1394.355` |
| **Platform** | `linux/amd64` only |
| **Base** | Node.js 20 |
| **Framework** | NestJS |
| **Exposed port** | `3000/tcp` |

## HTTP Endpoints

| Method | Path | Response | Status |
|--------|------|----------|--------|
| `GET` | `/` | `Hello World!` | 200 |
| `GET` | `/health` | `OK` | 200 |
| `GET` | `/metrics` | Prometheus text format | 200 |

## Startup Logs

```txt
> anal-test@0.0.1 start:prod
> node dist/main


[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [NestFactory] Starting Nest application...
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [InstanceLoader] PrometheusModule dependencies initialized +27ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [InstanceLoader] AppModule dependencies initialized +0ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RoutesResolver] AppController {/}: +7ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RouterExplorer] Mapped {/, GET} route +2ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RouterExplorer] Mapped {/metrics, GET} route +1ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RouterExplorer] Mapped {/health, GET} route +0ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RoutesResolver] PrometheusController {/metrics}: +0ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [RouterExplorer] Mapped {/metrics, GET} route +2ms
[Nest] 18  - 02/10/2026, 5:51:51 PM     LOG [NestApplication] Nest application successfully started +6ms

Application is running on: http://[::1]:3000
```

Notes:
- Application starts <1s

## Prometheus Metrics

The `/metrics` endpoint outputs metric lines in Prometheus text format. 
All metrics use randomly generated fake data (names, emails, countries, job titles).

### Metric Summary

| Metric | Type | Labels | Description |
|--------|------|--------|-------------|
| `random_gauge_1` | gauge | `product`, `platform`, `email`, `name`, `country` | Random gauge with ~40 series, all values = 1 |
| `random_gauge_2` | gauge | `product`, `platform`, `email`, `name`, `country` | Same structure as random_gauge_1 |
| `random_gauge_3` | gauge | `product`, `platform`, `email`, `name`, `country` | Same structure as random_gauge_1 |
| `name_gauge` | gauge | `name`, `email`, `job` | Gauge with ~50 series, values 1-5 |
| `ordered_histogram` | histogram | `name`, `email` | Histogram with buckets: 0.1, 0.5, 1, 2.5, 5, 10, +Inf |
| `random_histogram` | histogram | `email`, `name` | Same bucket structure as ordered_histogram |

### Metrics Examples

#### random_gauge_1 (gauge)
```
# HELP random_gauge_1 random_gauge_1
# TYPE random_gauge_1 gauge
random_gauge_1{product="Stella_Carter@hotmail.com",platform="Eunice",email="Leonor_Moore@yahoo.com",name="Jaiden",country="Serbia"} 1
random_gauge_1{product="Arnold_Dach42@gmail.com",platform="Dylan",email="Yolanda.Satterfield27@gmail.com",name="Ernesto",country="Guam"} 1
random_gauge_1{product="Rusty63@hotmail.com",platform="Maybelle",email="Frederic67@gmail.com",name="Velma",country="Switzerland"} 1
```

#### name_gauge (gauge)
```
# HELP name_gauge name_gauge
# TYPE name_gauge gauge
name_gauge{name="Mathias",email="Nannie.Zemlak@hotmail.com",job="Human Solutions Supervisor"} 2
name_gauge{name="Nia",email="Billie72@gmail.com",job="Forward Markets Consultant"} 4
name_gauge{name="Jean",email="Gustave_Wiza@gmail.com",job="Central Operations Coordinator"} 5
```

#### ordered_histogram (histogram)
```
# HELP ordered_histogram ordered_histogram
# TYPE ordered_histogram histogram
ordered_histogram_bucket{le="0.1",name="Francesco",email="Lukas54@hotmail.com"} 0
ordered_histogram_bucket{le="0.5",name="Francesco",email="Lukas54@hotmail.com"} 0
ordered_histogram_bucket{le="1",name="Francesco",email="Lukas54@hotmail.com"} 0
ordered_histogram_bucket{le="2.5",name="Francesco",email="Lukas54@hotmail.com"} 0
ordered_histogram_bucket{le="5",name="Francesco",email="Lukas54@hotmail.com"} 1
ordered_histogram_bucket{le="10",name="Francesco",email="Lukas54@hotmail.com"} 2
ordered_histogram_bucket{le="+Inf",name="Francesco",email="Lukas54@hotmail.com"} 2
ordered_histogram_sum{name="Francesco",email="Lukas54@hotmail.com"} 11.880855042873156
ordered_histogram_count{name="Francesco",email="Lukas54@hotmail.com"} 2
```

#### random_histogram (histogram)
```
# HELP random_histogram random_histogram
# TYPE random_histogram histogram
random_histogram_bucket{le="0.1",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 0
random_histogram_bucket{le="0.5",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 0
random_histogram_bucket{le="1",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 0
random_histogram_bucket{le="2.5",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 0
random_histogram_bucket{le="5",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 0
random_histogram_bucket{le="10",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 1
random_histogram_bucket{le="+Inf",email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 1
random_histogram_sum{email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 6.408892935019408
random_histogram_count{email="Rosamond_Kuhn5@gmail.com",name="Kamryn"} 1
```

## Discovery Commands Used

```bash
# Run the container
docker run --platform linux/amd64 -d --name spam2000-test -p 3000:3000 andriiuni/spam2000:1.1394.355

# Check logs
docker logs spam2000-test

# Inspect config
docker inspect spam2000-test

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/metrics

# Count metrics
curl -s http://localhost:3000/metrics | wc -l
curl -s http://localhost:3000/metrics | grep "^# TYPE"

# Cleanup
docker rm -f spam2000-test
```
