import type {
    Dispatch,
    ReactNode,
    SetStateAction,
    SyntheticEvent,
} from 'react';

import type { FieldValues } from 'react-hook-form';

import type {
    Debt,
    FlashState,
    ModeState,
} from '../types';

import { useState } from 'react';
import { useForm, Controller } from 'react-hook-form';

import { post } from '../server';
import CurrencyInput from './CurrencyInput';

interface NewSplitCardProps {
    flashState: FlashState,
    handleCloseCard: (event: SyntheticEvent) => void,
    modeState: ModeState,
    peopleOptions: ReactNode,
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

interface NewSplitFormErrors {
    amount?: string[],
    date?: string[],
    payee?: string[],
}

interface NewSplitFormResponse {
    debts: Debt[],
    errors: NewSplitFormErrors,
}

type Owed = 'self' | 'other person';

interface NewSplitFormInputs extends FieldValues {
    owed: Owed,
    person: {
        id: number,
    },
    split: {
        amount: number,
        date: string,
        memo: string,
        payee: string,
    },
};

export default function NewSplitCard(props: NewSplitCardProps) {

    const {
        control,
        handleSubmit,
        register,
    } = useForm<NewSplitFormInputs>();

    const [formErrorsState, setFormErrorsState] = useState<NewSplitFormErrors>({});

    const onSubmit = (formData: NewSplitFormInputs) => {
        props.setModeState({ mode: 'create split' });
        post('/splits', formData)
            .then((response) => response.json())
            .then((data: NewSplitFormResponse) => {
                if ("errors" in data) {
                    setFormErrorsState(data.errors);
                    props.setModeState({ mode: 'new split' });
                } else if ("debts" in data) {
                    setFormErrorsState({});
                    props.setDebtsState((data as { "debts": Debt[] }).debts);
                    props.setModeState({ mode: "idle" });
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Split was successfully created."]]
                    });
                }
            })
            .catch((error: unknown) => {
                console.log(error);
                props.setFlashState({
                    counter: props.flashState.counter + 1,
                    messages: [["danger", "There was an error with the network request."]]
                })
                props.setModeState({ mode: "idle" });
            })
    };

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">New Split</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <label className="label" htmlFor="split_date">Date</label>
                            <div className="control">
                                <input
                                    className={"input" + (formErrorsState.date ? " is-danger" : "")}
                                    id="split_date"
                                    type="date"
                                    {...register("split.date")}
                                />
                            </div>
                            {formErrorsState.date && <p className="help is-danger">{formErrorsState.date[0]}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_payee">Payee</label>
                            <div className="control">
                                <input
                                    className={"input" + (formErrorsState.payee ? " is-danger" : "")}
                                    id="split_payee"
                                    type="text"
                                    {...register("split.payee")}
                                />
                            </div>
                            {formErrorsState.payee && <p className="help is-danger">{formErrorsState.payee[0]}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_memo">Memo</label>
                            <div className="control">
                                <input className="input" type="text" {...register("split.memo")} id="split_memo" />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_amount">Amount</label>
                            <div className="control has-icons-left">
                                <Controller
                                    name="split.amount"
                                    control={control}
                                    render={({ field }) => (
                                        <CurrencyInput
                                            className={"input" + (formErrorsState.amount ? " is-danger" : "")}
                                            id="split_amount"
                                            onValueChange={(value) => { field.onChange(value); }}
                                            value={field.value}
                                        />
                                    )}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                            {formErrorsState.amount && <p className="help is-danger">{formErrorsState.amount[0]}</p>}
                        </div>
                        <div className="field">
                            <label className="label">Split Type</label>
                            <div className="control">
                                <label className="radio">
                                    <input type="radio" {...register("owed")} value="self" defaultChecked={true} /> paid by you and split with...
                                </label>
                                <br />
                                <label className="radio">
                                    <input type="radio" {...register("owed")} value="other person" /> paid by...
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
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <button type="submit" className={"card-footer-item button is-link" + (props.modeState.mode === 'create split' ? ' is-loading' : '')}>
                        Create
                    </button>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );

}
