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

export interface PersonAmount extends Person {
    dollarAmount: number,
}

export interface PersonOwed extends PersonAmount {
    cumulativeSum: number,
    date: string,
}

export interface PersonTransfer extends PersonOwed {
    personId: number,
    inYnab?: boolean,
}

export interface Transfer {
    date: string,
    dollarAmountPaid: number,
    memo: string,
    myPersonTransfer: PersonTransfer,
    payee: string,
    otherPersonTransfers: PersonTransfer[],
    transferId: number,
    type: "Expense" | "Payback",
}

export type ExpenseValidatableField = "expense.date" | "expense.dollar_amount_paid" | "expense.payee";

export interface ExpenseResponse {
    "person.transfers"?: Transfer[],
    "expense.errors"?: object
};
