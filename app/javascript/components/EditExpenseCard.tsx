import type { SyntheticEvent, Dispatch, SetStateAction } from 'react';
import type { FieldValues } from 'react-hook-form';

import type { Transfer, ModeState, ExpenseResponse, FlashState } from '../types';

import { useState }  from 'react';
import { useForm }  from 'react-hook-form';

import { patch, destroy }  from '../server';
import { setExpenseErrors } from '../form_helpers';

interface EditExpenseCardProps {
    expense: Transfer,
    flashState: FlashState,
    handleCloseCard: (event:SyntheticEvent) => void,
    modeState: ModeState,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    setTransfersState: Dispatch<SetStateAction<Transfer[]>>,
};

export interface EditExpenseFormInputs extends FieldValues {
    expense: {
        date: string,
        dollar_amount_paid: number,
        memo: string,
        payee: string,
    },
    my_person_transfer: {
        dollar_amount: number,
        id: number,
        in_ynab: boolean,
    },
    other_person_transfers: {
        dollar_amount: number,
        id: number,
    }[],
};

export default function EditExpenseCard(props:EditExpenseCardProps) {

    const {
        clearErrors,
        formState: { errors },
        handleSubmit,
        register,
        setError,
    } = useForm<EditExpenseFormInputs>();

    const onSubmit = (formData:EditExpenseFormInputs) =>  {
        props.setModeState({mode: 'update expense', expenseId: props.expense.transferId});
        patch('/expenses/' + props.expense.transferId.toString(), formData)
           .then((response) => response.json())
           .then((data:ExpenseResponse) => {
                if (setExpenseErrors(data, setError)) {
                    props.setModeState({mode: 'edit expense', expenseId: props.expense.transferId});
                } else if ("person.transfers" in data) {
                    clearErrors();
                    props.setTransfersState((data as {"person.transfers": Transfer[]})["person.transfers"]);
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Expense was successfully updated."]]
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

    const otherPersonFields = props.expense.otherPersonTransfers.map((personTransfer, index) => {
        const htmlId = "other_person_transfers_" + index.toString() + "_dollar_amount";
        // eslint-disable-next-line @typescript-eslint/prefer-optional-chain
        const theseErrors = errors.other_person_transfers && errors.other_person_transfers[index];
        return (
            <div key={"other-person-transfer-" + personTransfer.id.toString()} className="field">
                <input
                    type="hidden"
                    {...register("other_person_transfers." + index.toString() + ".id", {value: personTransfer.id})}
                />
                <label className="label" htmlFor={htmlId}>{personTransfer.name}'s Contribution</label>
                <div className="control has-icons-left">
                    <input
                        className={"input" + (theseErrors?.dollar_amount ? " is-danger" : "")}
                        id={htmlId}
                        step="0.01"
                        type="number"
                        {...register("other_person_transfers." + index.toString() + ".dollar_amount", {value: personTransfer.dollarAmount})}
                    />
                    <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                </div>
                {theseErrors?.dollar_amount && <p className="help is-danger">{theseErrors.dollar_amount.message}</p>}
            </div>
        );
    });

    const [deleteModalState, setDeleteModalState] = useState(false);

    const handleDelete = (event:SyntheticEvent) => {
        event.preventDefault();
        setDeleteModalState(false);
        props.setModeState({mode: 'idle'});
        destroy('/expenses/' + props.expense.transferId.toString())
           .then((response) => response.json())
           .then((data:ExpenseResponse) => {
                if ("person.transfers" in data) {
                    props.setTransfersState((data as {"person.transfers": Transfer[]})["person.transfers"]);
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Expense was successfully deleted."]]
                    })
                    props.setModeState({mode: "idle"});
                }
           })
           .catch((error:unknown) => {
                console.log(error);
                props.setFlashState({
                    counter: props.flashState.counter + 1,
                    messages:  [["danger", "There was an error with the deletion."]]
                });
           });
    };

    const deleteModal = deleteModalState && (
        <div className="modal is-active">
          <div className="modal-background" onClick={() => { setDeleteModalState(false) }}></div>
          <div className="modal-card">
            <header className="modal-card-head">
              <p>Are you sure you want to delete this expense?</p>
            </header>
            <footer className="modal-card-foot">
              <div className="buttons">
                <button className="button is-danger" onClick={handleDelete}>Delete</button>
                <button className="button" onClick={() => { setDeleteModalState(false) }}>Cancel</button>
              </div>
            </footer>
          </div>
          <button className="modal-close is-large" aria-label="close" onClick={() => { setDeleteModalState(false) }}></button>
        </div>
    );

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <input
                type="hidden"
                {...register("my_person_transfer.id", {value: props.expense.myPersonTransfer.id})}
            />
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Expense</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
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
                                <input
                                    className={"input" + (errors.expense?.dollar_amount_paid ? " is-danger" : "")}
                                    id="expense_dollar_amount_paid"
                                    min="0"
                                    step="0.01"
                                    type="number"
                                    {...register("expense.dollar_amount_paid", {value: props.expense.dollarAmountPaid})}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                            {errors.expense?.dollar_amount_paid && <p className="help is-danger">{errors.expense.dollar_amount_paid.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="my_person_transfer_dollar_amount">Your Contribution</label>
                            <div className="control has-icons-left">
                                <input
                                    className={"input" + (errors.my_person_transfer?.dollar_amount ? " is-danger" : "")}
                                    id="my_person_transfer_dollar_amount"
                                    step="0.01"
                                    type="number"
                                    {...register("my_person_transfer.dollar_amount", {value: props.expense.myPersonTransfer.dollarAmount})}
                                />
                                <span className="icon is-small is-left"><i className="fa-solid fa-dollar-sign" aria-hidden="true"></i></span>
                            </div>
                            {errors.my_person_transfer?.dollar_amount && <p className="help is-danger">{errors.my_person_transfer.dollar_amount.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="my_person_transfer_in_ynab">
                                <input
                                    id="my_person_transfer_in_ynab"
                                    type="checkbox"
                                    value="1"
                                    {...register("my_person_transfer.in_ynab", {value: props.expense.myPersonTransfer.inYnab})}
                                /> In YNAB?
                            </label>
                        </div>
                        {otherPersonFields}
                        <div className="field">
                            <label className="label" htmlFor="expense_date">Date</label>
                            <div className="control">
                                <input
                                    className={"input" + (errors.expense?.date ? " is-danger" : "")}
                                    id="expense_date"
                                    type="date"
                                    {...register("expense.date", {value: props.expense.date})}
                                />
                            </div>
                            {errors.expense?.date && <p className="help is-danger">{errors.expense.date.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_payee">Payee</label>
                            <div className="control">
                                <input
                                    className={"input" + (errors.expense?.payee ? " is-danger" : "")}
                                    id="expense_payee"
                                    type="text"
                                    {...register("expense.payee", {value: props.expense.payee})}
                                />
                            </div>
                            {errors.expense?.payee && <p className="help is-danger">{errors.expense.payee.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="expense_memo">Memo</label>
                            <div className="control">
                                <input
                                    className="input"
                                    id="expense_memo"
                                    type="text"
                                    {...register("expense.memo", {value: props.expense.memo})}
                                />
                            </div>
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <button type="submit" className={"card-footer-item button is-link" + (props.modeState.mode === 'update expense' ? ' is-loading' : '')}>
                        Update
                    </button>
                    <a href="#" className="card-footer-item has-text-danger" onClick={(e) => { e.preventDefault(); setDeleteModalState(true) }}>Delete</a>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
            {deleteModal}
        </form>
    );
}