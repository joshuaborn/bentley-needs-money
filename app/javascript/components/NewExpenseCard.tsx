import type { SyntheticEvent, ReactNode } from "react";

interface NewExpenseCardProps {
    handleCloseCard: (event:SyntheticEvent) => void,
    peopleOptions: ReactNode
};

export default function NewExpenseCard({handleCloseCard, peopleOptions}:NewExpenseCardProps) {
    return (
        <form action={(formData) => { console.log(formData) }}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">New Expense</p>
                    <a href="#" className="card-header-icon" onClick={handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <div className="control has-icons-left">
                                <input step="0.01" min="0" className="input" type="number" defaultValue="0.00" name="expense[dollar_amount_paid]" id="expense_dollar_amount_paid" />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                        <div className="field">
                            <div className="control">
                                <label className="radio">
                                    <input type="radio" name="person_paid" value="current" defaultChecked={true} />
                                    paid by you and split with...
                                </label>
                                <br/>
                                <label className="radio">
                                    <input type="radio" name="person_paid" value="other" />
                                    paid by...
                                </label>
                            </div>
                        </div>
                        <div className="field">
                            <div className="control has-icons-left has-icons-right">
                                <select className="input" name="person[id]" id="person_id">
                                    {peopleOptions}
                                </select>
                                <span className="icon is-small is-left">
                                    <i className="fas fa-user" aria-hidden="true"></i>
                                </span>
                                <span className="icon is-right">
                                    <i className="fa-solid fa-caret-down" aria-hidden="true"></i>
                                </span>
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_date">Date</label>
                            <div className="control">
                                <input className="input" type="date" name="expense[date]" id="expense_date" />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_payee">Payee</label>
                            <div className="control">
                                <input className="input" type="text" name="expense[payee]" id="expense_payee" />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_memo">Memo</label>
                            <div className="control">
                                <input className="input" type="text" name="expense[memo]" id="expense_memo" />
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