import type { UseFormSetError } from 'react-hook-form';

import type { ExpenseValidatableField, ExpenseResponse, PaybackValidatableField, PaybackResponse } from './types';
import type { NewExpenseFormInputs } from './components/NewExpenseCard';
import type { EditExpenseFormInputs } from './components/EditExpenseCard';
import type { NewPaybackFormInputs } from './components/NewPaybackCard';

export function setExpenseErrors(data:ExpenseResponse, setError:UseFormSetError<NewExpenseFormInputs|EditExpenseFormInputs>) {
    if (data["expense.errors"]) {
        for (const [key, value] of Object.entries(data["expense.errors"])) {
            const messages = value as string[];
            for (const message of messages) {
                setError(
                    key as ExpenseValidatableField,
                    { type: 'custom', message: message }
                );
            }
        }
        return true;
    }
    return false;
}

export function setPaybackErrors(data:PaybackResponse, setError:UseFormSetError<NewPaybackFormInputs>) {
    if (data["payback.errors"]) {
        for (const [key, value] of Object.entries(data["payback.errors"])) {
            const messages = value as string[];
            for (const message of messages) {
                setError(
                    key as PaybackValidatableField,
                    { type: 'custom', message: message }
                );
            }
        }
        return true;
    }
    return false;
}