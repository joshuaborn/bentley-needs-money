import { useState }  from 'react';
import type { ModeState } from '../types';
import ActionBar from './ActionBar';
import SidePanel from './SidePanel';
import MainPanel from './MainPanel';

export default function TransfersIndex() {
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    
    return (
        <div className="outer-flex">
            <div className="inner-flex columns is-gapless">
                <SidePanel modeState={modeState} setModeState={setModeState} />
                <MainPanel />
            </div>
            <ActionBar modeState={modeState} setModeState={setModeState} />
        </div>
    );
}