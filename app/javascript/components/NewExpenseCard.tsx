import type { Dispatch, SetStateAction, SyntheticEvent, ReactNode } from 'react';
import type { FieldValues } from 'react-hook-form';

import type { ModeState, Transfer } from '../types';

import { useForm }  from 'react-hook-form';

import { post } from '../server';

interface NewExpenseCardProps {
    handleCloseCard: (event:SyntheticEvent) => void,
    modeState: ModeState,
    peopleOptions: ReactNode,
    setFlashState: Dispatch<SetStateAction<string[][]>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    setTransfersState: Dispatch<SetStateAction<Transfer[]>>,
};

interface NewExpenseFormInputs extends FieldValues {
    expense: {
        date: string,
        dollar_amount_paid: number,
        memo: string,
        payee: string,
    },
    person: {
        id: number,
    }
    person_paid: string,
};

type NewExpenseValidatableField = "expense.date" | "expense.dollar_amount_paid" | "expense.payee";

interface NewExpenseResponse {
    "person.transfers"?: Transfer[],
    "expense.errors"?: object
};

export default function NewExpenseCard(props:NewExpenseCardProps) {
    const {
        clearErrors,
        formState: { errors },
        handleSubmit,
        register,
        setError,
    } = useForm<NewExpenseFormInputs>();
    const onSubmit = (formData:NewExpenseFormInputs) =>  {
        props.setModeState({mode: 'create expense'});
        post('/expenses', formData)
            .then((response) => response.json())
            .then((data:NewExpenseResponse) => {
                if (data["expense.errors"]) {
                    for (const [key, value] of Object.entries(data["expense.errors"])) {
                        const messages = value as string[];
                        for (const message of messages) {
                            setError(
                                key as NewExpenseValidatableField,
                                { type: 'custom', message: message }
                            );
                        }
                    }
                    props.setModeState({mode: 'new expense'});
                } else if ("person.transfers" in data) {
                    clearErrors();
                    props.setTransfersState((data as {"person.transfers": Transfer[]})["person.transfers"]);
                    props.setFlashState([["success", "Expense was successfully created."]])
                    props.setModeState({mode: "idle"});
                }
            })
            .catch((error:unknown) => {
                console.log(error);
                props.setFlashState([["danger", "There was an error with the network request."]])
                props.setModeState({mode: "idle"});
            })
    };
    const loadingClassName = (props.modeState.mode === 'create expense') ? ' is-loading' : '';
    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">New Expense</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <div className="control has-icons-left">
                                <input
                                    className={"input" + (errors.expense?.dollar_amount_paid ? " is-danger" : "")}
                                    defaultValue="0.00"
                                    id="expense_dollar_amount_paid"
                                    min="0"
                                    step="0.01"
                                    type="number"
                                    {...register("expense.dollar_amount_paid")}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                            {errors.expense?.dollar_amount_paid && <p className="help is-danger">{errors.expense.dollar_amount_paid.message}</p>}
                        </div>
                        <div className="field">
                            <div className="control">
                                <label className="radio">
                                    <input type="radio" {...register("person_paid")} value="current" defaultChecked={true} />
                                    paid by you and split with...
                                </label>
                                <br/>
                                <label className="radio">
                                    <input type="radio" {...register("person_paid")} value="other" />
                                    paid by...
                                </label>
                            </div>
                        </div>
                        <div className="field">
                            <div className="control has-icons-left has-icons-right">
                                <select className="input" {...register("person.id")} id="person_id">
                                    {props.peopleOptions}
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
                                <input
                                    className={"input" + (errors.expense?.date ? " is-danger" : "")}
                                    id="expense_date"
                                    type="date"
                                    {...register("expense.date")}
                                />
                            </div>
                            {errors.expense?.date && <p className="help is-danger">{errors.expense.date.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="payee">Payee</label>
                            <div className="control">
                                <input
                                    className={"input" + (errors.expense?.payee ? " is-danger" : "")}
                                    id="payee"
                                    type="text"
                                    {...register("expense.payee")}
                                />
                            </div>
                            {errors.expense?.payee && <p className="help is-danger">{errors.expense.payee.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_memo">Memo</label>
                            <div className="control">
                                <input className="input" type="text" {...register("expense.memo")} id="expense_memo" />
                            </div>
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <button type="submit" className={"card-footer-item button is-link" + loadingClassName}>
                        Create
                    </button>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );
}