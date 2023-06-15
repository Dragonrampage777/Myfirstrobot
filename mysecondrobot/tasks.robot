*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images..

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.Archive


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    open robot order site
    rid of popup
    Download order file
    Convert to Excel & Download

Creates ZIP archive of the receipts and the images..
    creates

LOGOUT
    Log out and close the browser


*** Keywords ***
open robot order site
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

rid of popup
    Click Button    OK

Download order file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Execute orders
    [Arguments]    ${order}
    Select From List By Index    ${order}[Head]

inject
    [Arguments]    ${order}
    Log    ${order}
    Select From List By Index    head    ${order}[Head]
    Click Button    id-body-${order}[Body]
    Input Text    css:.form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image
    Click Button    order

check for error
    [Arguments]    ${order}
    Wait Until Element Is Visible    robot-preview-image
    TRY
        Wait Until Element Is Visible    receipt    1
    EXCEPT    Element 'receipt' not visible after 1 second.
        inject    ${order}
        check for error    ${order}
    END

Saves the order HTML receipt as a PDF file
    [Arguments]    ${order}
    ${sale_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sale_receipt}    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}${order}[Order number].pdf
    Click Button    order-another
    rid of popup

Convert to Excel & Download
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${order}    IN    @{orders}
        inject    ${order}
        check for error    ${order}
        Saves the order HTML receipt as a PDF file    ${order}
    END
    Log out and close the browser

Log out and close the browser
    Close Browser
    Log    FINISHED

creates
    Archive Folder With Zip    ${OUTPUT_DIR}    receipts.zip
