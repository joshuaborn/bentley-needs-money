import type { SyntheticEvent } from "react";

interface NewPaybackCardProps {
    handleCloseCard: (event:SyntheticEvent) => void
};

export default function NewPaybackCard({handleCloseCard}:NewPaybackCardProps) {
    return (
        <form action={(formData) => { console.log(formData) }}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Pay Back</p>
                    <a href="#" className="card-header-icon" onClick={handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <label className="label" htmlFor="person_id">Person</label>
                            <div className="control has-icons-left has-icons-right">
                                <select className="input" name="person[id]" id="person_id">
                                    <option value="3">Jeanne K</option>
                                </select>
                                <span className="icon is-small is-left">
                                    <i className="fas fa-user" aria-hidden="true"></i>
                                </span>
                                <span className="icon is-right">
                                    <i className="fa-solid fa-caret-down" aria-hidden="true"></i>
                                </span>
                            </div>
                        </div>
                        <div className="field amount" id="payback_amount_3">
                            <label className="label" htmlFor="payback_dollar_amount_paid">Amount</label>
                            <div className="control has-icons-left">
                                <input step="0.01" defaultValue="-487.09" className="input" type="number" name="payback[dollar_amount_paid]" id="payback_dollar_amount_paid" />
                                <span className="icon is-small is-left">
                                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                                </span>
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="payback_date">Date</label>
                            <div className="control">
                                <input className="input" defaultValue={new Date().toISOString().slice(0, 10)} type="date" name="payback[date]" id="payback_date" />
                            </div>
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <input type="submit" name="commit" value="Create" className="card-footer-item button is-link" />
                    <a href="#" className="card-footer-item" onClick={handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );
}