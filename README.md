# ML QA Engineer GET Performance Test - ml-performance-test
- [x] Used PowerShells Invoke-WebRequest with over 1000 GET requests to https://www.magicleap.com and a custom function that utilizes Google Charts API and ConvertTo-HTML to make an interactive HTML report
- [x] Used Apache Benchmark with over 1000 GET requests to https://www.magicleap.com and generated a report in .CSV

### Test 3 PowerShell [Windows 10 x64]:
- [x] Wrote a performance test that does over 1000 GET's of https://www.magicleap.com utilizing PowerShell's I
- [x] Invoke-WebRequest and generated a report utilizing Google Charts & ConvertTo-HTML
- PowerSHell Report Name - ml_load_report.html
### Test 3 Bash [Debian]:
- [x] Wrote a performance test that does over 1000 GET's of https://www.magicleap.com with bash and utilizing Apache Benchmark that outputs a report to CSV
- [x] Bash report name - report_apache_benchmark.csv

### Running the Tests (based on Windows 10 x64, WSL - Debian, Mac OS Mojave ):
#### Pre-requisites for Powershell
- [x] "Set-ExecutionPolicy unrestricted -force" in elevated powershell (not always necessary)
- [x] Right-Click > Test3_powershell.ps1 > Run in Powershell
- [x] In elevated powershell session - ./Test3_powershell.ps1

### Pre-requiestes for Bash
- Need Apache Benchmark [apche2-utils](https://packages.debian.org/stretch/apache2-utils) 
$ sudo apt-get install -y apache2-utils
$ ab -h
$ ./Test3_apache_benchmark.sh

### Results
- PowerShell
[ml-performance-test/ml_load_report.html]
- Bash
[report_apache_benchmark.csv](../master/)