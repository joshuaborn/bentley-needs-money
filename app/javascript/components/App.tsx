import { useState }  from 'react';

import type { ModeState, Person, Transfer, PersonOwed } from '../types';
import ActionBar from './ActionBar';
import MainPanel from './MainPanel';
import SidePanel from './SidePanel';

interface AppProps {
    connectedPeople: Person[],
    initialFlash: string[][],
    initialPersonTransfers: Transfer[],
};

export default function App({connectedPeople, initialPersonTransfers, initialFlash}:AppProps) {
    const [flashState, setFlashState] = useState<string[][]>(initialFlash);
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    const [transfersState, setTransfersState] = useState<Transfer[]>(initialPersonTransfers);
    const peopleOwedMap = transfersState.reduce(
        function(accumulator, transfer) {
            transfer.otherPersonTransfers.forEach((personOwed) => {
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
                    connectedPeople={connectedPeople}
                    flash={flashState}
                    modeState={modeState}
                    peopleOwed={peopleOwed}
                    setFlashState={setFlashState}
                    setModeState={setModeState}
                    setTransfersState={setTransfersState}
                    transfers={transfersState}
                />
                <MainPanel
                    setModeState={setModeState}
                    transfers={transfersState}
                />
            </div>
            <ActionBar
                modeState={modeState}
                setModeState={setModeState}
            />
        </div>
    );
}