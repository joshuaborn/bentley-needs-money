import type {
    Dispatch,
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

import { patch } from '../server';
import DeleteModal from './DeleteModal';
import CurrencyInput from './CurrencyInput';

interface EditRepaymentCardProps {
    debt: Debt,
    flashState: FlashState,
    handleCloseCard: (event: SyntheticEvent) => void,
    modeState: ModeState,
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

export interface EditRepaymentFormInputs extends FieldValues {
    date: string,
    debts_attributes: {
        amount: number,
        id: number,
    }[],
};

export interface EditRepaymentFormErrors {
    date?: string[],
    "debts.amount"?: string[],
    debts?: string[],
}

export interface EditRepaymentFormResponse {
    debts: Debt[],
    errors: EditRepaymentFormErrors,
}

export default function EditRepaymentCard(props: EditRepaymentCardProps) {

    const {
        control,
        handleSubmit,
        register,
    } = useForm<EditRepaymentFormInputs>({
        defaultValues: {
            date: props.debt.reason.date,
            debts_attributes: [{
                id: props.debt.id,
                amount: props.debt.amount
            }]
        }
    });

    const [formErrorsState, setFormErrorsState] = useState<EditRepaymentFormErrors>({});

    const onSubmit = (formData: EditRepaymentFormInputs) => {
        props.setModeState({ mode: 'update repayment', repaymentId: props.debt.reason.id });
        patch('/repayments/' + props.debt.reason.id.toString(), formData)
            .then((response) => response.json())
            .then((data: EditRepaymentFormResponse) => {
                if ("errors" in data) {
                    setFormErrorsState(data.errors);
                    props.setModeState({ mode: 'edit repayment', repaymentId: props.debt.reason.id });
                } else if ("debts" in data) {
                    setFormErrorsState({});
                    props.setDebtsState((data as { "debts": Debt[] }).debts);
                    props.setModeState({ mode: "idle" });
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Repayment was successfully updated."]]
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

    const [deleteModalState, setDeleteModalState] = useState(false);

    const handleDelete = (data: Promise<EditRepaymentFormResponse>) => {
        setDeleteModalState(false);
        if ("debts" in data) {
            props.setDebtsState((data as { "debts": Debt[] }).debts);
            props.setFlashState({
                counter: props.flashState.counter + 1,
                messages: [["success", "Repayment was successfully deleted."]]
            })
            props.setModeState({ mode: "idle" });
        }
    };

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Repayment</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
                        <span className="icon">
                            <i className="fa-solid fa-xmark fa-lg has-text-link" aria-hidden="true"></i>
                        </span>
                    </a>
                </header>
                <div className="card-content">
                    <div className="content">
                        <div className="field">
                            <label className="label" htmlFor="repayment_date">Date</label>
                            <div className="control">
                                <input
                                    className={"input" + (formErrorsState.date ? " is-danger" : "")}
                                    id="repayment_date"
                                    type="date"
                                    {...register("date")}
                                />
                            </div>
                            {formErrorsState.date && <p className="help is-danger">{formErrorsState.date[0]}</p>}
                        </div>
                        <div className="field">
                            <div className="label">
                                Person
                            </div>
                            <div className="control">
                                {props.debt.person.name}
                            </div>
                        </div>
                        <div className="field amount">
                            <label className="label" htmlFor="repayment_amount_paid">Amount</label>
                            <div className="control has-icons-left">
                                <Controller
                                    name="debts_attributes[0].amount"
                                    control={control}
                                    render={({ field }) => (
                                        <CurrencyInput
                                            className={"input" + (formErrorsState["debts.amount"] ? " is-danger" : "")}
                                            id={"repayment_debt_" + props.debt.id.toString() + "_amount"}
                                            onValueChange={(value: number) => { field.onChange(value); }}
                                            value={field.value as number | undefined}
                                        />
                                    )}
                                />
                                <span className="icon is-small is-left">
                                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                                </span>
                            </div>
                            {formErrorsState["debts.amount"] && <p className="help is-danger">{formErrorsState["debts.amount"][0]}</p>}
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <button type="submit" className={"card-footer-item button is-link" + (props.modeState.mode === 'update repayment' ? ' is-loading' : '')}>
                        Update
                    </button>
                    <a href="#" className="card-footer-item has-text-danger" onClick={(e) => { e.preventDefault(); setDeleteModalState(true) }}>Delete</a>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
            {deleteModalState && <DeleteModal
                label="expense"
                onCancel={() => { setDeleteModalState(false) }}
                onDelete={handleDelete}
                urlPath={'/repayments/' + props.debt.reason.id.toString()}
            />}
        </form>
    );

}