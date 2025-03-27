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

import { useState }  from 'react';
import { useForm }  from 'react-hook-form';

import { patch } from '../server';
import DeleteModal from './DeleteModal';

interface EditSplitCardProps {
    debt: Debt,
    flashState: FlashState,
    handleCloseCard: (event:SyntheticEvent) => void,
    modeState: ModeState,
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

interface EditSplitFormInputs extends FieldValues {
    date: string,
    payee: string,
    memo: string,
    dollar_amount: number,
    debts_attributes: {
        id: number,
        dollar_amount: number,
    }[],
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

export default function EditSplitCard(props:EditSplitCardProps) {
    
    const split = props.debt.reason;

    const {
        handleSubmit,
        register,
    } = useForm<EditSplitFormInputs>();

    const [formErrorsState, setFormErrorsState] = useState<EditSplitFormErrors>({});

    const onSubmit = (formData:EditSplitFormInputs) =>  {
        props.setModeState({mode: 'update split', splitId: split.id});
        patch('/splits/' + split.id.toString(), formData)
           .then((response) => response.json())
           .then((data:EditSplitFormResponse) => {
                if ("errors" in data) {
                    setFormErrorsState(data.errors);
                    props.setModeState({mode: 'edit split', splitId: split.id});
                } else if ("debts" in data) {
                    setFormErrorsState({});
                    props.setDebtsState((data as {"debts": Debt[]}).debts);
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Split was successfully updated."]]
                    });
                    props.setModeState({mode: "idle"});
                }
            })
           .catch((error:unknown) => {
                console.log(error);
                props.setFlashState({
                    counter: props.flashState.counter,
                    messages: [["danger", "There was an error with the network request."]]
                });
                props.setModeState({mode: "idle"});
           })
    };

    const [deleteModalState, setDeleteModalState] = useState(false);

    const handleDelete = (data:Promise<EditSplitFormResponse>) => {
        setDeleteModalState(false);
        if ("debts" in data) {
            props.setDebtsState((data as {"debts": Debt[]}).debts);
            props.setFlashState({
                counter: props.flashState.counter + 1,
                messages: [["success", "Split was successfully deleted."]]
            })
            props.setModeState({mode: "idle"});
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
                                    {...register("date", {value: split.date})}
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
                                    {...register("payee", {value: split.payee})}
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
                                    {...register("memo", {value: split.memo})}
                                />
                            </div>
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="split_dollar_amount">Amount</label>
                            <div className="control has-icons-left">
                                <input
                                    className="input"
                                    id="split_dollar_amount"
                                    step="0.01"
                                    type="number"
                                    {...register("dollar_amount", {value: split.dollarAmount})}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                        </div>
                    </div>
                    <div className="field">
                        <input
                            type="hidden"
                            {...register("debts_attributes[0].id", {value: props.debt.id})}
                        />
                        <label className="label" htmlFor={"split_debt_" + props.debt.id.toString() + "_dollar_amount"}>{debtAmountLabel}</label>
                        <div className="control has-icons-left">
                            <input
                                className={"input" + (formErrorsState["debts.amount"] ? " is-danger" : "")}
                                id={"split_debt_" + props.debt.id.toString() + "_dollar_amount"}
                                step="0.01"
                                min="0"
                                type="number"
                                {...register("debts_attributes[0].dollar_amount", {value: props.debt.dollarAmount})}
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