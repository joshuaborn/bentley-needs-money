import { johnSmith, billyBob } from './people';
import type { ReasonType } from '../../../app/javascript/types';

const debts = [
    {
        id: 1,
        amount: 100,
        cumulativeSum: 100,
        reconciled: false,
        person: johnSmith,
        reason: {
            id: 1,
            type: 'Split' as ReasonType,
            date: '2024-05-14',
            amount: 200,
            payee: 'Payee 1',
            memo: ''

        }
    },
    {
        id: 2,
        amount: 150,
        cumulativeSum: 250,
        reconciled: false,
        person: johnSmith,
        reason: {
            id: 2,
            type: 'Split' as ReasonType,
            date: '2024-05-15',
            amount: 300,
            payee: 'Payee 2',
            memo: ''

        }
    },
    {
        id: 3,
        amount: 1000,
        cumulativeSum: 1000,
        reconciled: false,
        person: billyBob,
        reason: {
            id: 3,
            type: 'Split' as ReasonType,
            date: '2024-05-16',
            amount: 2000,
            payee: 'Payee 3',
            memo: ''

        }
    },
    {
        id: 4,
        amount: 500,
        cumulativeSum: 1500,
        reconciled: false,
        person: billyBob,
        reason: {
            id: 4,
            type: 'Split' as ReasonType,
            date: '2024-05-17',
            amount: 3000,
            payee: 'Payee 4',
            memo: ''

        }
    },
    {
        id: 5,
        amount: 10000,
        cumulativeSum: 11500,
        reconciled: false,
        person: billyBob,
        reason: {
            id: 5,
            type: 'Split' as ReasonType,
            date: '2024-05-18',
            amount: 20000,
            payee: 'Payee 5',
            memo: ''
        }
    },
]

export { debts }