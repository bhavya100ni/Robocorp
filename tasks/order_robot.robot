*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium        #auto_close=${FALSE}
Library           SeleniumLibrary
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           Collections
Library           RPA.RobotLogListener

*** Variables ***
${pdf_folder} =    ${OUTPUT_DIR}${/}pdf_folder
${zip_file} =      ${OUTPUT_DIR}${/}pdf.zip
${img_folder}     ${CURDIR}${/}image_files
${output_folder}  ${CURDIR}${/}output

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the intranet website
    ${orders}=    Get orders

    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        
        Wait Until Keyword Succeeds     10x     2s    Preview the order
        Wait Until Keyword Succeeds     10x     2s    Submit The Order
        # TRY
        #     Submit the order
        # EXCEPT    It is an exception
        #     Preview the order    
         
        # END
        ${orderId}    ${image_file} =    Take a screenshot    
        ${pdf_file} =    Store the order receipt as a pdf file    ORDER_NUMBER=${order_id}
        Embed the screenshot to pdf    ${pdf_file}    ${image_file}    
        Order Another Robot
    END
    Create a Zip File of the Receipts
    
*** Keywords ***
Open the intranet website
    
    RPA.Browser.Selenium.Create Webdriver    Chrome    executable_path=C:/Users/Bhavya Soni/chromedriver_win32/chromedriver.exe
    RPA.Browser.Selenium.Go To       https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True     
    ${table}=   Read table from CSV    ${OUTPUT_DIR}${/}orders.csv
    [Return]       ${table} 

Close the annoying modal
    Wait And Click Button       //div[@role='dialog']//button[1]

Fill the form 
    [Arguments]    ${myrow}
    RPA.Browser.Selenium.Wait Until Element Is Visible     //*[@id="head"]
    RPA.Browser.Selenium.Wait Until Element Is Enabled     //*[@id="head"]
    RPA.Browser.Selenium.Select From List By Value   //*[@id="head"]    ${myrow}[Head]
    RPA.Browser.Selenium.Wait Until Element Is Enabled    body
    RPA.Browser.Selenium.Select Radio Button   body    ${myrow}[Body]
    RPA.Browser.Selenium.Wait Until Element Is Enabled     //html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    RPA.Browser.Selenium.Input Text    //html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${myrow}[Legs]
    RPA.Browser.Selenium.Wait Until Element Is Enabled   address
    RPA.Browser.Selenium.Input Text    address    ${myrow}[Address]

Preview the order
    RPA.Browser.Selenium.Click Button    (//button[@id='preview'])[1]
    RPA.Browser.Selenium.Wait Until Element Is Visible    (//div[@id='robot-preview'])[1]
    #Sleep    10


Submit the order
    Mute Run On Failure             Page Should Contain Element
    RPA.Browser.Selenium.Click Button    Order
    RPA.Browser.Selenium.Page Should Contain Element            (//div[@id='receipt'])[1]
    # #Sleep    10
   
Order Another Robot
    RPA.Browser.Selenium.Click Button     (//button[@id='order-another'])[1]

 Fill and submit the form for robot
    RPA.Browser.Selenium.Click Button        //div[@role='dialog']//button[1]
    RPA.Browser.Selenium.Select From List By Value      //*[@id="head"]       1
    RPA.Browser.Selenium.Select Radio Button    body        1
    RPA.Browser.Selenium.Input Text         //html/body/div/div/div[1]/div/div[1]/form/div[3]/input       4
    RPA.Browser.Selenium.Input Text    address    Address123
    RPA.Browser.Selenium.Click Button    Order 

Store the order receipt as a pdf file
    [Arguments]    ${orderNo}
    Set Local Variable              ${final_pdf}    ${pdf_folder}${/}${orderNo}.pdf
    ${orderReceipt}=    RPA.Browser.Selenium.Get Element Attribute     id:receipt    outerHTML
    Html To Pdf    ${orderReceipt}    ${final_Pdf}  
    [Return]    ${final_pdf}  

Take a screenshot
    # [Arguments]    ${orderid}
    ${orderid}=      RPA.Browser.Selenium.Get Text          //*[@id="receipt"]/p[1]
    Set Local Variable              ${final_image}      ${img_folder}${/}${orderid}.png
    RPA.Browser.Selenium.Capture Element Screenshot      (//div[@id='robot-preview'])[1]      ${final_image}
    
    [Return]    ${orderid}     ${final_image}
    

Embed the screenshot to pdf
    [Arguments]    ${pdf}     ${images}
    Open Pdf    ${pdf}
    @{files} =    Create List    ${images}:x=0,y=0
    Add Files To Pdf    ${files}    ${pdf}
    Close Pdf    ${pdf}  

Create a Zip File of the Receipts
    Archive Folder With ZIP     ${pdf_folder}  ${zip_file}   recursive=True  include=*.pdf

Log out and close the browser
    RPA.Browser.Selenium.Click Button    Log out
    RPA.Browser.Selenium.Close Browser    