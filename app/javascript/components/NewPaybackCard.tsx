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
    PersonTransfer,
    Transfer,
} from '../types';

import { useForm }  from 'react-hook-form';

import { post } from '../server';
import { setPaybackErrors } from '../form_helpers';

interface NewPaybackCardProps {
    flashState: FlashState,
    handleCloseCard: (event:SyntheticEvent) => void,
    modeState: ModeState,
    peopleOwed: PersonTransfer[],
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    setTransfersState: Dispatch<SetStateAction<Transfer[]>>,
};

export interface NewPaybackFormInputs extends FieldValues {
    payback: {
        date: string,
        dollar_amount_paid: number,
    },
    person: {
        id: number,
    },
};

export default function NewPaybackCard(props:NewPaybackCardProps) {

    const peopleOptions = props.peopleOwed.map((person) => {
        return <option key={person.personId} value={person.personId}>{person.name}</option>;
    });
    
    const {
        clearErrors,
        formState: { errors },
        getValues,
        handleSubmit,
        register,
        setError,
        setValue,
    } = useForm<NewPaybackFormInputs>({
        defaultValues: {
            payback: {
                dollar_amount_paid: props.peopleOwed[0] ? props.peopleOwed[0].cumulativeSum * -1 : 0,
                date: new Date().toISOString().slice(0, 10),
            },
            person: {
                id: props.peopleOwed[0] ? props.peopleOwed[0].personId : undefined,
            }
        }
    });

    const onSubmit = (formData:NewPaybackFormInputs) =>  {
        props.setModeState({mode: 'create payback'});
        post('/paybacks', formData)
            .then((response) => response.json())
            .then((data:PaybackResponse) => {
                if (setPaybackErrors(data, setError)) {
                    // props.setModeState({mode: 'new payback'});
                } else if ("person.transfers" in data) {
                    clearErrors();
                    props.setTransfersState((data as {"person.transfers": Transfer[]})["person.transfers"]);
                    props.setModeState({mode: "idle"});
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Payback was successfully created."]]
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
    
    const handlePersonChange = () => {
        const newPerson = props.peopleOwed.find((personTransfer) => personTransfer.personId == getValues('person.id'));
        if (newPerson) {
            setValue('payback', { date: getValues('payback.date'), dollar_amount_paid: newPerson.cumulativeSum * -1});
        }
    };

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Pay Back</p>
                    <a href="#" className="card-header-icon" onClick={props.handleCloseCard}>
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
                                <select
                                    className="input"
                                    id="person_id"
                                    {...register("person.id", { onChange: handlePersonChange})}
                                >
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
                                    {...register("payback.date", {value: new Date().toISOString().slice(0, 10)})}
                                />
                            </div>
                            {errors.payback?.date && <p className="help is-danger">{errors.payback.date.message}</p>}
                        </div>
                    </div>
                </div>
                <footer className="card-footer buttons has-addons">
                    <input type="submit" name="commit" value="Create" className="card-footer-item button is-link" />
                    <a href="#" className="card-footer-item" onClick={props.handleCloseCard}>Cancel</a>
                </footer>
            </div>
        </form>
    );

}