import type {
    SyntheticEvent,
    Dispatch,
    SetStateAction,
} from 'react';

import type { FieldValues } from 'react-hook-form';

import type {
    Debt,
    FlashState,
    ModeState,
} from '../types';

import { useState } from 'react';
import { useForm, Controller } from 'react-hook-form';

import { patch } from '../server';
import DeleteModal from './DeleteModal';
import CurrencyInput from './CurrencyInput';

interface EditSplitCardProps {
    debt: Debt,
    flashState: FlashState,
    handleCloseCard: (event: SyntheticEvent) => void,
    modeState: ModeState,
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

interface EditSplitFormInputs extends FieldValues {
    amount: number,
    date: string,
    debts_attributes: {
        amount: number,
        id: number,
    }[],
    memo: string,
    payee: string,
};

interface EditSplitFormErrors {
    date?: string[],
    "debts.amount"?: string[],
    debts?: string[],
    payee?: string[],
}

export interface EditSplitFormResponse {
    debts: Debt[],
    errors: EditSplitFormErrors,
}

export default function EditSplitCard(props: EditSplitCardProps) {

    const split = props.debt.reason;

    const {
        control,
        handleSubmit,
        register,
    } = useForm<EditSplitFormInputs>({
        defaultValues: {
            date: split.date,
            payee: split.payee,
            memo: split.memo,
            amount: split.amount,
            debts_attributes: [{
                id: props.debt.id,
                amount: props.debt.amount
            }]
        }
    });

    const [formErrorsState, setFormErrorsState] = useState<EditSplitFormErrors>({});

    const onSubmit = (formData: EditSplitFormInputs) => {
        props.setModeState({ mode: 'update split', splitId: split.id });
        patch('/splits/' + split.id.toString(), formData)
            .then((response) => response.json())
            .then((data: EditSplitFormResponse) => {
                if ("errors" in data) {
                    setFormErrorsState(data.errors);
                    props.setModeState({ mode: 'edit split', splitId: split.id });
                } else if ("debts" in data) {
                    setFormErrorsState({});
                    props.setDebtsState((data as { "debts": Debt[] }).debts);
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Split was successfully updated."]]
                    });
                    props.setModeState({ mode: "idle" });
                }
            })
            .catch((error: unknown) => {
                console.log(error);
                props.setFlashState({
                    counter: props.flashState.counter,
                    messages: [["danger", "There was an error with the network request."]]
                });
                props.setModeState({ mode: "idle" });
            })
    };

    const [deleteModalState, setDeleteModalState] = useState(false);

    const handleDelete = (data: Promise<EditSplitFormResponse>) => {
        setDeleteModalState(false);
        if ("debts" in data) {
            props.setDebtsState((data as { "debts": Debt[] }).debts);
            props.setFlashState({
                counter: props.flashState.counter + 1,
                messages: [["success", "Split was successfully deleted."]]
            })
            props.setModeState({ mode: "idle" });
        }
    };

    let debtAmountLabel;
    if (props.debt.person.role === 'Ower') {
        debtAmountLabel = 'Amount ' + props.debt.person.name + ' owes';
    } else {
        debtAmountLabel = 'Amount owed to ' + props.debt.person.name;
    }

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Split</p>
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
                                    {...register("date")}
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
                                    {...register("payee")}
                                />
                            </div>
                            {formErrorsState.payee && <p className="help is-danger">{formErrorsState.payee[0]}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_memo">Memo</label>
                            <div className="control">
                                <input
                                    className="input"
                                    id="split_memo"
                                    type="text"
                                    {...register("memo")}
                                />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_amount">Amount</label>
                            <div className="control has-icons-left">
                                <Controller
                                    name="amount"
                                    control={control}
                                    render={({ field }) => (
                                        <CurrencyInput
                                            className="input"
                                            id="split_amount"
                                            onValueChange={(value) => { field.onChange(value); }}
                                            value={field.value}
                                        />
                                    )}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                    </div>
                    <div className="field">
                        <input
                            type="hidden"
                            {...register("debts_attributes[0].id")}
                        />
                        <label className="label" htmlFor={"split_debt_" + props.debt.id.toString() + "_amount"}>{debtAmountLabel}</label>
                        <div className="control has-icons-left">
                            <Controller
                                name="debts_attributes[0].amount"
                                control={control}
                                render={({ field }) => (
                                    <CurrencyInput
                                        className={"input" + (formErrorsState["debts.amount"] ? " is-danger" : "")}
                                        id={"split_debt_" + props.debt.id.toString() + "_amount"}
                                        onValueChange={(value: number) => { field.onChange(value); }}
                                        value={field.value as number | undefined}
                                    />
                                )}
                            />
                            <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                        </div>
                        {formErrorsState["debts.amount"] && <p className="help is-danger">{formErrorsState["debts.amount"][0]}</p>}
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <button type="submit" className={"card-footer-item button is-link" + (props.modeState.mode === 'update split' ? ' is-loading' : '')}>
                        Update
                    </button>
                    <a href="#" className="card-footer-item has-text-danger" onClick={(e) => { e.preventDefault(); setDeleteModalState(true) }}>Delete</a>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
            {deleteModalState && <DeleteModal
                label="split"
                onCancel={() => { setDeleteModalState(false) }}
                onDelete={handleDelete}
                urlPath={'/splits/' + split.id.toString()}
            />}
        </form>
    );
}