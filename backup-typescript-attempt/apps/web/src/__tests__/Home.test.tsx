// @atomfit/web/src/__tests__/Home.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Home } from '../screens/Home';

describe('Home screen', () => {
  it('renders welcome, monthly count, and empty-workout action', () => {
    render(<Home />);
    expect(screen.getByText(/Welcome back/)).toBeInTheDocument();
    expect(screen.getByText('Workouts this month')).toBeInTheDocument();
    expect(screen.getByText('Empty workout')).toBeInTheDocument();
  });
});
