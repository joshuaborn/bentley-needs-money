import type { SyntheticEvent } from "react";
import type { Transfer } from "../types";

interface EditExpenseCardProps {
    handleCloseCard: (event:SyntheticEvent) => void,
    expense: Transfer
};

export default function EditExpenseCard({handleCloseCard, expense}:EditExpenseCardProps) {
    const otherPersonFields = expense.otherPeople.map((personOwed) => {
        return (
            <div key={"other-person-" + personOwed.id.toString()} className="field">
                <label className="label" htmlFor="other_person_amount">{personOwed.name}'s Contribution</label>
                <div className="control has-icons-left">
                    <input step="0.01" className="input" type="number" defaultValue={personOwed.dollarAmount.toFixed(2)} name="other_person_amount" id="other_person_amount" />
                    <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                </div>
            </div>
        );
    });
    return (
        <form action={(formData) => { console.log(formData) }}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Expense</p>
                    <a href="#" className="card-header-icon" onClick={handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <label className="label" htmlFor="expense_dollar_amount_paid">Dollar Amount Paid</label>
                            <div className="control has-icons-left">
                                <input step="0.01" min="0" className="input" type="number" defaultValue={expense.dollarAmountPaid.toFixed(2)} name="expense[dollar_amount_paid]" id="expense_dollar_amount_paid" />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_person_transfers_attributes_0_dollar_amount">Your Contribution</label>
                            <div className="control has-icons-left">
                                <input step="0.01" className="input" type="number" defaultValue={expense.dollarAmount.toFixed(2)} name="expense[person_transfers_attributes][0][dollar_amount]" id="expense_person_transfers_attributes_0_dollar_amount" />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_person_transfers_attributes_0_in_ynab">
                                <input name="expense[person_transfers_attributes][0][in_ynab]" type="hidden" value="0" autoComplete="off" />
                                <input type="checkbox" value="1" defaultChecked={expense.inYnab} name="expense[person_transfers_attributes][0][in_ynab]" id="expense_person_transfers_attributes_0_in_ynab" /> In YNAB?
                            </label>
                        </div>
                        {otherPersonFields}
                        <div className="field">
                            <label className="label" htmlFor="expense_date">Date</label>
                            <div className="control">
                                <input className="input" defaultValue={expense.date} type="date" name="expense[date]" id="expense_date" />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_payee">Payee</label>
                            <div className="control">
                                <input className="input" type="text" defaultValue={expense.payee} name="expense[payee]" id="expense_payee" />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_memo">Memo</label>
                            <div className="control">
                                <input className="input" type="text" defaultValue={expense.memo} name="expense[memo]" id="expense_memo" />
                            </div>
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <input type="submit" name="commit" value="Update" className="card-footer-item button is-link" />
                    <a href={"/expenses/" + expense.id.toString()} className="card-footer-item has-text-danger">Delete</a>
                    <a href="#" className="card-footer-item" onClick={handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );
}