export type ModeState =
    | { mode: 'idle' }
    | { mode: 'new split' }
    | { mode: 'create split' }
    | { mode: 'edit split', splitId: number }
    | { mode: 'update split', splitId: number }
    | { mode: 'new repayment' }
    | { mode: 'create repayment' }
    | { mode: 'edit repayment', repaymentId: number }
    | { mode: 'update repayment', repaymentId: number }
;

export interface FlashState {
    counter: number,
    messages: string[][],
}

export type PersonRole = 'Ower' | 'Owed';

export interface Person {
    id: number,
    name: string,
    role: PersonRole,
}

export type ReasonType = 'Split' | 'Repayment';

export interface Reason {
    amount: number,
    date: string,
    id: number,
    memo: string,
    payee: string,
    type: ReasonType,
}

export interface Debt {
    amount: number,
    cumulativeSum: number,
    id: number,
    person: Person,
    reason: Reason,
    reconciled: boolean
}
