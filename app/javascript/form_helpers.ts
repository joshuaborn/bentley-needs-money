import type { UseFormSetError } from 'react-hook-form';

import type { ExpenseValidatableField, ExpenseResponse } from './types';
import type { NewExpenseFormInputs } from './components/NewExpenseCard';
import type { EditExpenseFormInputs } from './components/EditExpenseCard';

export function setErrorsFromResponse(data:ExpenseResponse, setError:UseFormSetError<NewExpenseFormInputs|EditExpenseFormInputs>) {
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