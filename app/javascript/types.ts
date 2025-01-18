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
    name: string,
}

export interface PersonOwed {
    cumulativeSum: number,
    date: string,
    dollarAmount: number,
    id: number,
    name: string,
}

export interface Transfer {
    date: string,
    dollarAmount: number,
    dollarAmountPaid: number,
    id: number,
    inYnab: boolean,
    memo: string,
    otherPeople: PersonOwed[],
    payee: string,
    transferId: number,
    type: "Expense" | "Payback",
}