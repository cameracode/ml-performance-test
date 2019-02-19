# ML QA Engineer GET Performance Test - ml-performance-test
Used PowerShells Invoke-WebRequest with over 1000 GETS to https://www.magicleap.com and a custom function that utilizes Google Charts API and ConvertTo-HTML to make an interactive HTML report
Used Apache Benchmark with over 1000 GETS to https://www.magicleap.com and generated a report in .CSV


### Test 3:
- [x] Wrote a performance test that does over 1000 GET's of https://www.magicleap.com utilizing PowerShell's Invoke-WebRequest and generated a report utilizing Google Charts & ConvertTo-HTML
- PowerSHell Report Name - ml_load_report.html
- [x] Wrote a performance test that does over 1000 GET's of https://www.magicleap.com with bash and utilizing Apache Benchmark that outputs a report to CSV
- Bash report name - report_apache_benchmark.csv

### Running the Tests (based on Windows 10 x64, WSL - Debian, Mac OS Mojave ):
#### Pre-requisites for Powershell
- "Set-ExecutionPolicy unrestricted -force" in elevated powershell (not always necessary)
- Right-Click Test3_powershell.ps1 > Run in Powershell
- In elevated powershell session - ./Test3_powershell.ps1

### Pre-requiest for Bash
- Need Apache Benchmark [apche2-utils](https://packages.debian.org/stretch/apache2-utils) 
$ sudo apt-get install -y apache2-utils
$ ./Test3_apache_benchmark.sh
### Results
- PowerShell
ml-performance-test/ml_load_report.html

- Bash
report_apache_benchmark.csv