import type { SyntheticEvent } from "react";
import type { Transfer } from "../types";

interface EditPaybackCardProps {
    handleCloseCard: (event:SyntheticEvent) => void,
    payback: Transfer
};

export default function EditPaybackCard({handleCloseCard, payback}:EditPaybackCardProps) {
    return (
        <form action={(formData) => { console.log(formData) }}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Payback</p>
                    <a href="#" className="card-header-icon" onClick={handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <div className="label">
                                Person
                            </div>
                            <div className="control">
                                {payback.otherPeople[0].name}
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="payback_dollar_amount_paid">Amount</label>
                            <div className="control has-icons-left">
                                <input step="0.01" className="input" type="number" defaultValue={payback.dollarAmountPaid} name="payback[dollar_amount_paid]" id="payback_dollar_amount_paid" />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="payback_date">Date</label>
                            <div className="control">
                                <input className="input" defaultValue={payback.date} type="date" name="payback[date]" id="payback_date" />
                            </div>
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <input type="submit" name="commit" value="Update" className="card-footer-item button is-link" />
                    <a href="#" className="card-footer-item has-text-danger">Delete</a>
                    <a href="#" className="card-footer-item" onClick={handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );
}