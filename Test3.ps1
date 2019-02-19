 <#
    .SYNOPSIS
        HTTP GET Request
    .DESCRIPTION
    .NOTES
        Author:             Eben Yep (New-GoogleChart function by Martin Pugh)
        E-mail:             ebenofthecamera@gmail.com
        Changelog:
            1.0             Initial Release
    .LINK
#>
$PSScriptRoot   = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$report_path    = $PSScriptRoot + "\ml_load_report.html"
$csv_path       = $PSScriptRoot + "\response_times.csv"
$csv_avg_path   = $PSScriptRoot + "\minmaxavg_response_times.csv"

# script inputs
$url = 'https://www.magicleap.com'
$Iterations = 1000

# initialize counter to 0 and set dictionary to empty
$i = 0
$resp_dict = @{}

Function New-GoogleChart
{   <#
    .SYNOPSIS
        Create line or bar charts using Google visualizations
    .DESCRIPTION
        This function will take a PowerShell object and help you create a line or bar chart using Google visualizations.  The function will return an object with 2 properties:
        
            jscript             jScript text that must be included in the <HEAD> section of your HTML
            id                  Name of the class you must use to call the chart up in your HTML.  Can 
                                be a class for a <DIV>, <TD> etc.  
                                
        As noted above, you must include the jscript in the <HEAD> section of your HTML.  But this is not enough.  The jScript defines a class ID that you must then reference in the <BODY> of your HTML, this will define where the chart appears on your HTML page.
        
        **  Requires PowerShell 3.0 
        **  Internet connection
            
        Does send data to Google to create the chart, do not use if you have some security or other reason for not wanting to send data to Google, then DO NOT use this function.
        
    .PARAMETER InputObject
        Specifies the objects to be represented in chart. Enter a variable that contains the objects or type a command or expression that gets the objects.
    .PARAMETER ChartType
        Three types of charts are supported at this time.  Line, LineSoft and Bar.  Line is a classic line chart, while LineSoft is also a line chart, but the edges are curved instead of the typical jagged angles.  Bar is for a classic bar chart.
    .PARAMETER XAxis
        Defines which property will be the x-axis of the chart.  There can only be ONE x-axis.
    .PARAMETER YAxis
        Defines which property or properties will be the y-axis of the chart.
    .PARAMETER LegendLocation
        Defines where on the chart the legend will appear.  Valid entries are Top, Bottom, Left or Right.
    .PARAMETER Title
        Define the title that will appear in the chart
    .PARAMETER ChartNumber
        If you want to have multiple charts on your HTML page you need to define ChartNumber.  Each chart must have a different number.
    .PARAMETER Orientation
        By default, chart orientation is horizontal.  Use this parameter to change your chart to a vertical orientation.
    .INPUTS
        Any PowerShell object
    .OUTPUTS
        PSCustomObject
            jscript
            id
    .EXAMPLE
        Sample data:
            Date,Frogs,Eagles,Pigs
            1/10,10,35,4
            1/11,3,44,8
            1/12,8,12,12
            1/13,1,2,3
            1/14,13,35,10
            1/15,18,44,22
        
        Data is loaded into a variable called $CSV.  
        
        $Chart1 = $CSV | New-GoogleChart -XAxis Date -YAxis Frogs,Eagles,Pigs -Title "Sales To Date" -LegendLocation Right -ChartType LineSoft
        
        This will take $CSV and create the jscript using Date as the x-axis and Frogs, Eagles and Pegs as the y-axis.  The chart will be a line chart with soft corners.  To make HTML you can:
        
        $Header = @"
        <style>
        H1 {color: #000099;}
        TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse; clear:both;}
        TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;font-size:1.5em;}
        TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
        DIV {float: left;}
        </style>
        $($Chart1.jscript)      <---Important!
        "@
        $CSV | ConvertTo-Html -Head $Header -Body "<div id=""$($Chart1.id)""></div>" | Out-File c:\Test\testchart.html -Encoding ASCII
                                                  [-----------Must Have!-----------]
        
        $($Chart1.jscript) in the $Header variable inserts the JavaScript into the <HEAD> section of the HTML.  In the Body parameter a <div> is defined using the "id" property from the function.  
    .EXAMPLE
        $Chart1 = $CSV | New-GoogleChart -XAxis Date -YAxis Frogs,Eagles,Pigs -Title "Sales To Date" -LegendLocation Right -ChartType LineSoft
        $Chart2 = $CSV | New-GoogleChart -XAxis Date -YAxis Frogs,Pigs -Title "More Sales" -LegendLocation Bottom -ChartType Bar -ChartNumber 1
        $Header = @"
        $($Chart1.jscript)
        $($Chart2.jscript)
        "@
        $CSV | ConvertTo-Html -Head $Header -Body "<div id=""$($Chart1.id)""></div><div id=""$($Chart2.id)""></div>" | Out-File c:\Test\testchart.html -Encoding ASCII
    
        This will create two charts in your HTML.  You are not limited to using ConvertTo-HTML either, you can manually create the HTML if you wish, too.
        
    .NOTES
        Author:             Martin Pugh
        Twitter:            @thesurlyadm1n
        Spiceworks:         Martin9700
        Blog:               www.thesurlyadmin.com
          
        Changelog:
            1.0             Initial Release
    .LINK
        http://community.spiceworks.com/scripts/show/2526-create-a-chart-in-powershell-new-googlechart
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]$InputObject,
        [ValidateSet("Line","LineSoft","Bar")]
        [string]$ChartType = "Line",
        [Parameter(Mandatory)]
        [string]$XAxis,
        [Parameter(Mandatory)]
        [String[]]$YAxis,
        [ValidateSet("Top","Bottom","Left","Right")]
        [string]$LegendLocation = "Top",
        [string]$Title,
        [int]$ChartNumber = 0,
        [Switch]$Orientation
    )
    
    Begin {
        Write-Verbose "$(Get-Date): New-GoogleChart function started"
        $Script = @"

<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
    google.load("visualization", "1", {packages:["corechart"]});
    google.setOnLoadCallback(drawChart);
    function drawChart() {
        var grid = google.visualization.arrayToDataTable([
"@
        Switch ($ChartType)
        {   "Line" 
            {   $CurveType = "curveType: 'none',"
                $CT = "LineChart"
                Break
            }
            "LineSoft"
            {   $CurveType = "curveType: 'function',"
                $CT = "LineChart"
                Break
            }
            "Bar"
            {   $CT = "BarChart"
                $CurveType = $null
                Break
            }
        }
        
        If ($Orientation)
        {   $O = "orientation: 'vertical',"
        }
        Else
        {   $O = "orientation: 'horizontal',"
        }
        $ReturnObject = @()
    }
    
    End {
        Write-Verbose "$(Get-Date): Building jscript..."
        $Data = @($Input)
        
        #Validate properties
        $Properties = $Data[0] | Get-Member -MemberType *Properties | Select -ExpandProperty Name
        If ($Properties -notcontains $XAxis)
        {   Write-Warning "X-Axis: $XAxis does not exist in the property list of the object passed to the function."
            Exit
        }
        ForEach ($Property in $YAxis)
        {   If ($Properties -notcontains $Property)
            {   Write-Warning "Y-Axis: $Property does not exist in the property list of the object passed to the function."
                Exit
            }
        }
        
        $Grid = "`n            ['$($XAxis)'"
        ForEach($Index in (0..($YAxis.Count - 1)))
        {   $Grid += ", '$($YAxis[$Index])'"
        }
        $Grid += "],`n"
        ForEach ($Line in $Data)
        {   $Grid += "            ['$($Line.$XAxis)'"
            ForEach ($Property in $YAxis)
            {   $Grid += ", $($Line.$Property)"
            }
            $Grid += "],`n"
        }
        $Grid = $Grid.Substring(0,$Grid.Length - 2) + "`n"
        $id = "chart$($ChartNumber)_id"
        $Script += @"
$Grid
        ]);       
        var options$ChartNumber = {
            title: '$Title',
            $O
            $CurveType
            legend: { position: '$($LegendLocation.ToLower())' }
        };
        
        var chart$ChartNumber = new google.visualization.$CT(document.getElementById('$id'));
        chart$ChartNumber.draw(grid, options$ChartNumber);
    }
</script>
"@
        $ReturnObject += [PSCustomObject]@{
            jscript = $Script
            id = $id
        }
        Write-Verbose "$(Get-Date): New-GoogleChart function completed"
        Return $ReturnObject
    }
}

While ($i -lt $Iterations)
{
    # track execution time:
    $timeTaken = Measure-Command -Expression `
    {
        # GET Request of the Site
        $site = Invoke-WebRequest -Uri $url -Method Get
    }

    $milliseconds = $timeTaken.TotalMilliseconds
    $milliseconds = [Math]::Round($milliseconds, 1)

    $resp_dict.Add($i, $milliseconds)
    "Request $i took $milliseconds ms" | Write-Host -ForegroundColor Green
    $i++
}

# Measure and process to CSV for the New-GoogleChart function
$measure = $resp_dict.Values | Measure -Average -Minimum -Maximum
$resp_dict.GetEnumerator() | Select-Object @{ expression={$_.name}; label="Iteration"},@{ expression={$_.Value}; label="Response_Time"} | Sort-Object Iteration | Export-Csv -Path $csv_path
$measure | Export-Csv -Path $csv_avg_path

$CSV    = Import-Csv $csv_path
$CSV2   = Import-CSV $csv_avg_path

# MIN, MAX, & AVG
$measure_min = $measure.Minimum 
$measure_max = $measure.Maximum
$measure_avg = $measure.Average

$Chart1 = $CSV | New-GoogleChart -XAxis Iteration -YAxis Response_Time -Title "Response Time in MS during 1000 Iterations" -LegendLocation Right -ChartType LineSoft
$Chart2 = $CSV2 | New-GoogleChart -XAxis Maximum -YAxis Minimum,Maximum,Average -Title "Site Response Times in MS: Min,Max,Avg" -LegendLocation Right -ChartType Bar -ChartNumber 1
$Header = @"
<Title>MagicLeap.com Performance Test</Title>
$($Chart1.jscript)
$($Chart2.jscript)
"@

# Convert array to HTML and output to HTML file in CWD
$resp_time = $CSV | Select Iteration,Response_Time | ConvertTo-Json 

$convert =  ConvertTo-Html -Head $Header -Body `
            $("<div id=""$($Chart1.id)""></div>" +`
            "<div id=""$($Chart2.id)""></div>" +`
            "<div><center>Min Response Time: $measure_min ms</center></div>" +`
            "<div><center>Max Response Time: $measure_max ms</center></div>" +`
            "<div><center>Avg Response Time: $measure_avg ms</center></div>") | Out-File $report_path -Encoding ASCII

$Body = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}"
"@
$CSV | Select Iteration,Response_Time | ConvertTo-Html -Head $Body | Out-File $report_path -Encoding ascii -Append

" " | Write-Host
"Min Response Time: $measure_min ms" | Write-Host -ForegroundColor Green  
"Max Response Time: $measure_max ms" | Write-Host -ForegroundColor Green  
"Avg Response Time: $measure_avg ms" | Write-Host -ForegroundColor Green  

