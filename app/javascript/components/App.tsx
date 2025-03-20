import { useState }  from 'react';

import type { ModeState, FlashState, Person, Debt } from '../types';
import ActionBar from './ActionBar';
import MainPanel from './MainPanel';
import SidePanel from './SidePanel';

interface AppProps {
    connectedPeople: Person[],
    initialFlash: string[][],
    initialDebts: Debt[],
};

export default function App({connectedPeople, initialDebts, initialFlash}:AppProps) {
    const [flashState, setFlashState] = useState<FlashState>({
        counter: 0,
        messages: initialFlash
    });
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    const [debtsState, setDebtsState] = useState<Debt[]>(initialDebts);
    const peopleOwedMap = debtsState.reduce(
        function(accumulator, debt) {
            const currentEntry = accumulator.get(debt.person.id);
            if (typeof currentEntry === "undefined" || (currentEntry.reason.date < debt.reason.date)) {
                accumulator.set(debt.person.id, debt);
            }
            return accumulator;
        },
        new Map<number,Debt>()
    );
    const peopleOwed = Array.from(peopleOwedMap).map(([, value]) => (value));
    
    return (
        <div className="outer-flex">
            <div className="inner-flex columns is-gapless">
                <SidePanel
                    connectedPeople={connectedPeople}
                    flashState={flashState}
                    modeState={modeState}
                    peopleOwed={peopleOwed}
                    setFlashState={setFlashState}
                    setModeState={setModeState}
                    setDebtsState={setDebtsState}
                    debts={debtsState}
                />
                <MainPanel
                    setModeState={setModeState}
                    debts={debtsState}
                />
            </div>
            <ActionBar
                modeState={modeState}
                setModeState={setModeState}
            />
        </div>
    );
}