//
//  Help.swift
//  cfleaseplus
//
//  Created by Steven Williams on 7/4/23.
//

import Foundation

struct Help {
    let title: String
    let instruction: String
}


let baseTermHelp =
    Help(title: "Base Term Start Date", instruction: "The date when the periodic payments commence.  If the base term start date occurs after the funding date then an interim term will be created and one non-periodic payment will added to the payment schedule. To remove an interim payment set the base start date equal to the funding date. For a monthly payment frequency the base start date cannot occur more than 90 days after the funding date. For all other payment frequencies the interim term cannot exceed the number of days in the payment frequency.")

let cutOffHelp: Help =
    Help(title: "Cut-Off Date", instruction: "A new Lease/Loan will be created from the payment groups of the existing Lease/Loan that occur on and after the cut-off date as selected by the user. If an EBO exists in the current Lease it will also be included in the new Lease if the cut-off date occurs before the EBO exercise date. The ideal application for the Cut-Off method is the purchase of a seasoned lease out of portfolio.")

let defaultNewHelp =
    Help(title: "Default New", instruction: "The default new lease/loan parameters can be set by the user. First, create the preferred lease/loan structure.  Then return to Preferences and switch on \"use saved\"  and switch on \"save current\". Thereafter, when New is selected from the Side Menu the user's saved lease/loan parameters will be loaded.  The default new parameters can be reset to the original parameters by turning off those same switches.")

let discountRateHelp =
    Help(title: "Specified Rate Help", instruction: "For accounting purposes the specified rate should be equal to the Lessee's Incremental Borrowing Rate (IBR).  The discount rate used to present value the minimum rents should then be the lesser of the IBR or the Implicit Rate.")

let decimalPadHelp = Help(title: "Keypad Buttons", instruction: "From left to right the buttons are Cancel, Copy to Clipboard, Paste from Clipboard, Clear All, and Enter.")

let eboHelp =
    Help(title: "Early Buyout", instruction: "The EBO exercise date must occur on or before one year prior to the Lease's maturity date but no earlier than the first anniversary date of the Lease.  The amount of the EBO must greater than 1.005% of the par value of the Lease on the EBO exercise date but less than or equal to the Lease Amount.")

let eboHelp2 =
    Help(title: "Early Buyout", instruction: "The EBO amount can be calculated given a spread in basis points over the lease interest rate, or it can entered manually.  If entered manually the spread will be automatically calculated. Upon returning to the EBO screen a specified EBO amount will be presented as a calculated amount. The slider value will be accurate to the calculated spread +/- 1 basis points.  To remove an EBO from reports set the slider value equal to 0 basis points.")

let eomRuleHelp =
    Help(title: "End of Month Rule", instruction: "If the base term commencement date starts on last day of a month with 30 days and the rule is on, then the payment due dates for the months with 31 days will occur on the 31st of the applicable month.  If the rule is off then payment due dates for the months with 31 days will occur on the 30th.")

let escalationRateHelp =
    Help(title: "Escalation Rate", instruction: "The total number of payments for the starting group must be evenly divisible by 12. The resulting escalated payment structure will be a series of consecutive annual payment groups in which the payment amount for each payment group is greater than the previous group by the amount of the escalation rate.")

let exportFileHelp =
    Help(title: "Export File Help", instruction: "When the export action is turned on, the above selected file can be exported to iCloud or to another location on the user's phone.  Once a file is located on the iCloud drive it may be shared with other users of CFLease.")

let feeNameHelp =
    Help(title: "Fee Name Help", instruction: "A valid fee is a string that is greater than 5 and less than 25 characters in length and does not include any illegal characters.")


let firstAndLastHelp =
    Help(title: "1stAndLast", instruction: "The last payment will be added to the first payment and the last payment will be set to 0.00.")

let graduationPaymentsHelp = Help(title: "Graduated Payments Help", instruction: "This structure primarily applies to fixed mortgages that have low initial monthly payment that gradually increase each year over a specified number of years. The rate of increase is set by the escalation rate and the number of years in which the monthly payments will increase is set by the number of annual steps.")

let implicitRateHelp =
    Help(title: "Implicit Rate Help", instruction: "The implicit rate is the discount rate that equates the present value of the Minimum Lease Payments and the unguaranteed residual value to the Lease Amount as of the funding date. Any fee that the Lessee is required to make in connection with the Lease is considered part of the Minimum Lease Payments. To remove a Customer Paid Fee from reports set the fee amount equal to 0.00.")

let importExportHelp =
    Help(title: "Import Export Help", instruction: "The importing and exporting of CFLease data files provide users with additional storage space and the ability to share data files with other CFLease users. Both capabilities are best achieved by using iCloud.")

let importFileHelp =
    Help(title: "Import File Help", instruction: "When the import action is activated, a valid CFLease data file can be imported from iCloud or from another location on the user's phone.  After importing, save the file locally by selecting File Save As from the Side Menu.")

let leaseBalanceHelp =
    Help(title: "Outstanding Balance Help", instruction: "The effective date can be any date occurring after the funding date and before the maturity date of the Lease/Loan. Upon clicking the done button, an amortization report is available for the Lease/Loan Balance through the effective date. Any subsequent recalculation of the Lease/Loan will remove the Balance calculation from reports. To manually remove a Balance calculation from reports set the effective date equal to the funding date.")

let operatingModeHelp =
    Help(title: "Operating Mode", instruction: "The app has two modes, leasing and lending. In the lending mode, the payment types are limited to interest only, payment, principal, and balloon and the timing of such payments is limited to in arrears. In the leasing mode payments can be made in advance or in arrears and there are 3 additional payment types - daily equivalent all (deAll), daily equivalent next (deNext), and residual. Adding a residual payment will unlock access to both the EBO and PV of Rent calculations.")

let myNewHelp =
    Help(title: "New Help", instruction: "This is a test.")

let paymentAmountHelp: Help =
    Help(title: "Payment Amount", instruction: "A valid payment amount must be a decimal => 0.00 and < 2x Lease/Loan Amount. Any decimal amount entered less than 1.00 will be interpreted as a percent of Lease/Loan Amount.  The percentage option is available throughout the program. For example, if the Lease/Loan Amount is 1,000,000.00, then an entry of 0.15 will be converted into an entry of 150,000.00.")

let purchaseHelp =
    Help(title: "Buy/Sell", instruction: "Enter a buy rate and the program will solve for the amount fee to be paid by the purchaser of the Lease/Loan (the Buy Fee) or vice versa. A negative Buy Fee cannot be entered, however, a Buy Rate higher than the Lease/Loan interest rate can be entered and will result in a negative Buy Fee.  To remove a buy fee from reports set the fee paid equal to 0.00 or set the buy rate equal to the Lease/Loan interest rate.")

let renameHelp =
    Help(title: "Rename Help", instruction: "In order to rename a file, the renaming section must be active, the current name of the file must exist in the collection, the new file name must not already exist in the collection, and it must be a valid file name.")

let saveAsHelp =
    Help(title: "Save As", instruction: "A legal file name must not already exist, must not contain any illegal characters, and must be less than 30 characters in length.")

let saveAsTemplateHelp = Help(title: "Save As Template", instruction: "The requirements for legal template file name are the same as a regular file name.  When naming a template do not add the suffix \"_tmp\" to the end of the template name.  That will be done by the program.  A template file cannot have an interim term.")

let solveForTermHelp =
    Help(title: "Solve For Term", instruction: "In order to solve for the term, there must be only one unlocked payment group.  Additionally, the number of payments for that group must greater than the minimum and less then the maximum number allowed. Finally, the payment type for that group cannot be interest only.")

let termAmortHelp =
    Help(title: "Amortization Term", instruction: "The amortization term is the number of months required to fully amortize the loan amount given the interest rate and a level payment structure. The program will then use that calculated payment as the payment amount for the current loan and then will calculate the balloon payment that will balance the loan. A 60-month loan at a 120-month amortization given a 5.00% interest rate will result in 56.2048% balloon payment.")

let terminationHelp = Help(title: "Termination Values", instruction: "TVs are a schedule of values in excess of the applicable lease balances for each payment date. For a non-true lease, setting the discount rate for rent equal to the buy rate will protect any fees paid to the buyer in the event of an unscheduled termination of the lease.  To remove TVs from reports set the discount rates for rent and residual to the maximum values and the additional residual percentage to 0.00%.")
