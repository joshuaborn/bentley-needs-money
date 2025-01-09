export type ModeState =
    | { mode: 'idle' }
    | { mode: 'new expense' }
    | { mode: 'create expense' }
    | { mode: 'edit expense', expenseId: number }
    | { mode: 'update expense', expenseId: number }
    | { mode: 'new payback' }
    | { mode: 'create payback' }
    | { mode: 'edit pabyack', paybackId: number }
    | { mode: 'update payback', paybackId: number }
;
