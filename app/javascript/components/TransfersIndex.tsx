import { useState }  from 'react';
import type { ModeState, Person, Transfer, PersonOwed } from '../types';
import ActionBar from './ActionBar';
import SidePanel from './SidePanel';
import MainPanel from './MainPanel';

interface TransfersIndexProps {
    connectedPeople: Person[],
    initialPersonTransfers: Transfer[],
    flash: string[][]
};

export default function TransfersIndex({connectedPeople, initialPersonTransfers, flash}:TransfersIndexProps) {
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    const [transfersState] = useState<Transfer[]>(initialPersonTransfers);
    const peopleOwedMap = transfersState.reduce(
        function(accumulator, transfer) {
            const currentEntry = accumulator.get(transfer.person_id);
            if (typeof currentEntry === "undefined" || (currentEntry.mostRecent < transfer.date)) {
                accumulator.set(
                    transfer.person_id,
                    {
                        id: transfer.person_id,
                        name: transfer.name,
                        cumulativeSum: transfer.cumulative_sum,
                        mostRecent: transfer.date
                    }
                );
            }
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