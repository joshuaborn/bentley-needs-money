export type ModeState =
    | { mode: 'idle' }
    | { mode: 'new expense' }
    | { mode: 'create expense' }
    | { mode: 'edit expense', expenseId: number }
    | { mode: 'update expense', expenseId: number }
    | { mode: 'new payback' }
    | { mode: 'create payback' }
    | { mode: 'edit payback', paybackId: number }
    | { mode: 'update payback', paybackId: number }
;

export interface Person {
    id: number,
    name: string
}

export interface PersonOwed {
    id: number,
    name: string,
    cumulativeSum: number,
    mostRecent: string
}

export interface Transfer {
    id: number,
    transfer_id: number,
    cumulative_sum: number,
    amount: number,
    in_ynab: boolean,
    person_id: number,
    name: string,
    date: string,
    amount_paid: number,
    payee: string,
    memo: string,
    type: "Expense" | "Payback"
}