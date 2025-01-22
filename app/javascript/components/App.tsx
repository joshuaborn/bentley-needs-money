import { useState }  from 'react';

import type { ModeState, Person, Transfer, PersonOwed } from '../types';
import ActionBar from './ActionBar';
import MainPanel from './MainPanel';
import SidePanel from './SidePanel';

interface AppProps {
    connectedPeople: Person[],
    flash: string[][],
    initialPersonTransfers: Transfer[],
};

export default function App({connectedPeople, initialPersonTransfers, flash}:AppProps) {
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    const [transfersState] = useState<Transfer[]>(initialPersonTransfers);
    const peopleOwedMap = transfersState.reduce(
        function(accumulator, transfer) {
            transfer.otherPeople.forEach((personOwed) => {
                const currentEntry = accumulator.get(personOwed.id);
                if (typeof currentEntry === "undefined" || (currentEntry.date < transfer.date)) {
                    accumulator.set(personOwed.id, personOwed);
                }
            });
            return accumulator;
        },
        new Map<number,PersonOwed>()
    );
    const peopleOwed = Array.from(peopleOwedMap).map(([, value]) => (value));
    
    return (
        <div className="outer-flex">
            <div className="inner-flex columns is-gapless">
                <SidePanel
                    modeState={modeState}
                    setModeState={setModeState}
                    connectedPeople={connectedPeople}
                    peopleOwed={peopleOwed}
                    flash={flash}
                    transfers={transfersState}
                />
                <MainPanel
                    transfers={transfersState}
                    setModeState={setModeState}
                />
            </div>
            <ActionBar modeState={modeState} setModeState={setModeState} />
        </div>
    );
}