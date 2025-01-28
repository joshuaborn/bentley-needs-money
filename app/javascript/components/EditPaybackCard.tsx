import type {
    Dispatch,
    SetStateAction,
    SyntheticEvent,
} from 'react';

import type { FieldValues } from 'react-hook-form';

import type { 
    FlashState,
    ModeState,
    PaybackResponse,
    Transfer,
} from '../types';

import { useForm }  from 'react-hook-form';

import { patch } from '../server';
import { setPaybackErrors } from '../form_helpers';

interface EditPaybackCardProps {
    flashState: FlashState,
    handleCloseCard: (event:SyntheticEvent) => void,
    payback: Transfer,
    modeState: ModeState,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    setTransfersState: Dispatch<SetStateAction<Transfer[]>>,
};

export interface EditPaybackFormInputs extends FieldValues {
    payback: {
        date: string,
        dollar_amount_paid: number,
        id: number,
    },
};

export default function EditPaybackCard(props:EditPaybackCardProps) {

    const {
        clearErrors,
        formState: { errors },
        handleSubmit,
        register,
        setError,
    } = useForm<EditPaybackFormInputs>({
        defaultValues: {
            payback: {
                date: props.payback.date,
                dollar_amount_paid: props.payback.dollarAmountPaid,
            }
        }
    });

    const onSubmit = (formData:EditPaybackFormInputs) =>  {
        props.setModeState({mode: 'update payback', paybackId: props.payback.transferId});
        patch('/paybacks/'+ props.payback.transferId.toString(), formData)
            .then((response) => response.json())
            .then((data:PaybackResponse) => {
                if (setPaybackErrors(data, setError)) {
                    props.setModeState({mode: 'edit payback', paybackId: props.payback.transferId});
                } else if ("person.transfers" in data) {
                    clearErrors();
                    props.setTransfersState((data as {"person.transfers": Transfer[]})["person.transfers"]);
                    props.setModeState({mode: "idle"});
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Payback was successfully updated."]]
                    });
                }
            })
            .catch((error:unknown) => {
                console.log(error);
                props.setFlashState({
                    counter: props.flashState.counter + 1,
                    messages: [["danger", "There was an error with the network request."]]
                })
                props.setModeState({mode: "idle"});
            })
    };

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Edit Payback</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
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
                                {props.payback.otherPersonTransfers[0].name}
                            </div>
                        </div>
                        <div className="field amount">
                            <label className="label" htmlFor="payback_dollar_amount_paid">Amount</label>
                            <div className="control has-icons-left">
                                <input
                                    className={"input" + (errors.payback?.dollar_amount_paid ? " is-danger" : "")}
                                    id="payback_dollar_amount_paid"
                                    step="0.01"
                                    type="number"
                                    {...register("payback.dollar_amount_paid")}
                                />
                                <span className="icon is-small is-left">
                                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                                </span>
                            </div>
                            {errors.payback?.dollar_amount_paid && <p className="help is-danger">{errors.payback.dollar_amount_paid.message}</p>}
                        </div>
                        <div className="field">
                            <label className="label" htmlFor="payback_date">Date</label>
                            <div className="control">
                                <input
                                    className={"input" + (errors.payback?.date ? " is-danger" : "")}
                                    id="payback_date"
                                    type="date"
                                    {...register("payback.date")}
                                />
                            </div>
                            {errors.payback?.date && <p className="help is-danger">{errors.payback.date.message}</p>}
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <input type="submit" name="commit" value="Update" className="card-footer-item button is-link" />
                    <a href="#" className="card-footer-item has-text-danger">Delete</a>
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );

}