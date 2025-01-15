import AmountField from './AmountField';
import { useState } from 'react';
import type { SyntheticEvent } from "react";
import type { PersonOwed } from '../types';

interface NewPaybackCardProps {
    handleCloseCard: (event:SyntheticEvent) => void,
    peopleOwed: PersonOwed[]
};

export default function NewPaybackCard({handleCloseCard, peopleOwed}:NewPaybackCardProps) {
    const peopleOptions = peopleOwed.map((person) => {
        return <option key={person.id} value={person.id}>{person.name}</option>;
    });
    const [personState, setPersonState] = useState<PersonOwed>(peopleOwed[0]);
    const handlePersonChange = (event:SyntheticEvent): void => {
        const newPersonId = parseInt((event.target as HTMLInputElement).value);
        const newPerson = peopleOwed.find((person) => person.id === newPersonId);
        if (newPerson) setPersonState(newPerson);
    };
    return (
        <form action={(formData) => { console.log(formData) }}>
            <div className="card">
                <header className="card-header">
                    <p className="card-header-title">Pay Back</p>
                    <a href="#" className="card-header-icon" onClick={handleCloseCard}>
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
                                <select className="input" name="person[id]" id="person_id" onChange={handlePersonChange}>
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
                        <AmountField
                            key={"amount-" + personState.id.toString()}
                            defaultAmount={personState.cumulativeSum} 
                            fieldName={"amount"}
                        />
                        <div className="field">
                            <label className="label" htmlFor="payback_date">Date</label>
                            <div className="control">
                                <input className="input" defaultValue={new Date().toISOString().slice(0, 10)} type="date" name="payback[date]" id="payback_date" />
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