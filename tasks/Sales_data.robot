*** Settings ***
Documentation     Insert the sales data for the week and export it as a PDF.
Library           RPA.Browser.Selenium        #auto_close=${FALSE}
Library           SeleniumLibrary
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF

*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open the intranet website
    Login
    Download the Excel file   
    # Fill and submit the form
    Fill the form using the data from the Excel file
    Collect the results
    Export the table as a PDF
    [Teardown]    Log out and close the browser


*** Keywords ***
Open the intranet website
    
    RPA.Browser.Selenium.Create Webdriver    Chrome    executable_path=C:/Users/Bhavya Soni/chromedriver_win32/chromedriver.exe
    RPA.Browser.Selenium.Go To       https://robotsparebinindustries.com/
   
Login
    RPA.Browser.Selenium.Input Text    username    maria
    RPA.Browser.Selenium.Input Password    password    thoushallnotpass
    RPA.Browser.Selenium.Submit Form
    RPA.Browser.Selenium.Wait Until Page Contains Element    id:sales-form

Fill and submit the form
    RPA.Browser.Selenium.Input Text    firstname    John
    RPA.Browser.Selenium.Input Text    lastname    Smith
    RPA.Browser.Selenium.Input Text    salesresult    123
    RPA.Browser.Selenium.Select From List By Value    salestarget    10000
    RPA.Browser.Selenium.Click Button    Submit

Download the Excel file
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True

Fill the form using the data from the Excel file
    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sales_rep}    IN    @{sales_reps}
        Fill and submit the form for one person    ${sales_rep}
    END

Fill and submit the form for one person
    [Arguments]    ${sales_rep}
    RPA.Browser.Selenium.Input Text    firstname    ${sales_rep}[First Name]
    RPA.Browser.Selenium.Input Text    lastname    ${sales_rep}[Last Name]
    RPA.Browser.Selenium.Input Text    salesresult    ${sales_rep}[Sales]
    RPA.Browser.Selenium.Select From List By Value    salestarget    ${sales_rep}[Sales Target]
    RPA.Browser.Selenium.Click Button    Submit

Collect the results
    RPA.Browser.Selenium.Screenshot    css:div.sales-summary    ${OUTPUT_DIR}${/}sales_summary.png

Export the table as a PDF
    RPA.Browser.Selenium.Wait Until Element Is Visible    id:sales-results
    ${sales_results_html}=    RPA.Browser.Selenium.Get Element Attribute    id:sales-results    outerHTML 
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}sales_results.pdf   

Log out and close the browser
    RPA.Browser.Selenium.Click Button    Log out
    RPA.Browser.Selenium.Close Browser