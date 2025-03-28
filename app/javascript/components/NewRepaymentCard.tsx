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
    Person,
} from '../types';

import { useState }  from 'react';
import { useForm }  from 'react-hook-form';

import { post } from '../server';

interface NewRepaymentCardProps {
    flashState: FlashState,
    handleCloseCard: (event:SyntheticEvent) => void,
    modeState: ModeState,
    peopleOwed: Debt[],
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

interface NewRepaymentFormErrors {
    amount?: string[],
    date?: string[],
}

interface NewRepaymentFormResponse {
    debts: Debt[],
    errors: NewRepaymentFormErrors,
}

type Repayer = 'self' | 'other person';

interface NewRepaymentFormInputs extends FieldValues {
    person: {
        id: number,
    },
    repayer: Repayer,
    repayment: {
        amount: number,
        date: string,
    },
};

export default function NewRepaymentCard(props:NewRepaymentCardProps) {

    const people = props.peopleOwed.map((debt) => {
        return [debt.person.id, debt.person.name];
    });
    const peopleOptions = people.map((tuple) => {
        return <option key={tuple[0]} value={tuple[0]}>{tuple[1]}</option>;
    });
    
    const {
        getValues,
        handleSubmit,
        register,
        setValue,
    } = useForm<NewRepaymentFormInputs>({
        defaultValues: {
            repayment: {
                date: new Date().toISOString().slice(0, 10),
                amount: props.peopleOwed[0] ? Math.abs(props.peopleOwed[0].cumulativeSum) / 100 : 0,
            },
            repayer: props.peopleOwed[0] && props.peopleOwed[0].cumulativeSum < -1 ? 'self' : 'other person',
            person: {
                id: props.peopleOwed[0] ? props.peopleOwed[0].person.id : undefined,
            }
        }
    });
    
    const [formErrorsState, setFormErrorsState] = useState<NewRepaymentFormErrors>({});

    const onSubmit = (formData:NewRepaymentFormInputs) =>  {
        props.setModeState({mode: 'create repayment'});
        post('/repayments', formData)
            .then((response) => response.json())
            .then((data:NewRepaymentFormResponse) => {
                if ("errors" in data) {
                    props.setModeState({mode: 'new repayment'});
                } else if ("debts" in data) {
                    setFormErrorsState({});
                    props.setDebtsState((data as {"debts": Debt[]}).debts);
                    props.setModeState({mode: "idle"});
                    props.setFlashState({
                        counter: props.flashState.counter + 1,
                        messages: [["success", "Repayment was successfully created."]]
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
    
    const [personState, setPersonState] = useState<Person>(props.peopleOwed[0]?.person); 
    
    const handlePersonChange = () => {
        const newPerson = props.peopleOwed.find((debt) => debt.person.id == getValues('person.id'));
        if (newPerson) {
            setValue('repayment', { date: getValues('repayment.date'), amount: Math.abs(newPerson.cumulativeSum) / 100});
            setValue('repayer', newPerson.cumulativeSum < -1 ? 'self' : 'other person');
            setPersonState(newPerson.person);
        }
    };

    return (
        // eslint-disable-next-line @typescript-eslint/no-misused-promises
        <form onSubmit={handleSubmit(onSubmit)}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">New Repayment</p>
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
                                    {...register("repayment.date")}
                                />
                            </div>
                            {formErrorsState.date && <p className="help is-danger">{formErrorsState.date[0]}</p>}
                        </div>
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
                            <label className="label" htmlFor="repayment_amount_paid">Amount</label>
                            <div className="control has-icons-left">
                                <input
                                    className={"input" + (formErrorsState.amount ? " is-danger" : "")}
                                    id="repayment_amount_paid"
                                    step="0.01"
                                    type="number"
                                    {...register("repayment.amount")}
                                />
                                <span className="icon is-small is-left">
                                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                                </span>
                            </div>
                            {formErrorsState.amount && <p className="help is-danger">{formErrorsState.amount[0]}</p>}
                        </div>
                        <div className="field">
                            <div className="control">
                                <label className="radio">
                                    <input type="radio" {...register("repayer")} value="self" /> from you to {personState.name}
                                </label>
                                <br/>
                                <label className="radio">
                                    <input type="radio" {...register("repayer")} value="other person" /> from {personState.name} to you
                                </label>
                            </div>
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