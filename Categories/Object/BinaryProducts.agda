{-# OPTIONS --universe-polymorphism #-}
open import Categories.Category

module Categories.Object.BinaryProducts {o ℓ e} (C : Category o ℓ e) where

open Category C
open Equiv

open import Level

import Categories.Object.Product as Product
open import Categories.Morphisms

open Product C

record BinaryProducts : Set (o ⊔ ℓ ⊔ e) where
  infix 10 _⁂_

  field
    product : ∀ {A B} → Product A B

  _×_ : Obj → Obj → Obj
  A × B = Product.A×B (product {A} {B})

  ×-comm : ∀ {A B} → _≅_ C (A × B) (B × A)
  ×-comm = Commutative product product

  ×-assoc : ∀ {X Y Z} → _≅_ C (X × (Y × Z)) ((X × Y) × Z)
  ×-assoc = Associative product product product product

  -- Convenience!
  π₁ : {A B : Obj} → ((A × B) ⇒ A)
  π₁ = Product.π₁ product

  π₂ : {A B : Obj} → ((A × B) ⇒ B)
  π₂ = Product.π₂ product

  ⟨_,_⟩ : ∀ {A B Q} → (Q ⇒ A) → (Q ⇒ B) → (Q ⇒ (A × B))
  ⟨_,_⟩ = Product.⟨_,_⟩ product

  .commute₁ : ∀ {A B C} {f : C ⇒ A} {g : C ⇒ B} → π₁ ∘ ⟨ f , g ⟩ ≡ f
  commute₁ = Product.commute₁ product

  .commute₂ : ∀ {A B C} {f : C ⇒ A} {g : C ⇒ B} → π₂ ∘ ⟨ f , g ⟩ ≡ g
  commute₂ = Product.commute₂ product

  .universal : ∀ {A B C} {f : C ⇒ A} {g : C ⇒ B} {i : C ⇒ (A × B)}
               → π₁ ∘ i ≡ f → π₂ ∘ i ≡ g → ⟨ f , g ⟩ ≡ i
  universal = Product.universal product

  assocˡ : ∀ {A B C} → (((A × B) × C) ⇒ (A × (B × C)))
  assocˡ = _≅_.g C ×-assoc

  assocʳ : ∀ {A B C} → ((A × (B × C)) ⇒ ((A × B) × C))
  assocʳ = _≅_.f C ×-assoc

  .g-η : ∀ {A B C} {f : C ⇒ (A × B)} → ⟨ π₁ ∘ f , π₂ ∘ f ⟩ ≡ f
  g-η = Product.g-η product

  .η : ∀ {A B} → ⟨ π₁ , π₂ ⟩ ≡ id {A × B}
  η = Product.η product

  .⟨⟩-cong₂ : ∀ {A B C} → {f f′ : C ⇒ A} {g g′ : C ⇒ B} → f ≡ f′ → g ≡ g′ → ⟨ f , g ⟩ ≡ ⟨ f′ , g′ ⟩
  ⟨⟩-cong₂ = Product.⟨⟩-cong₂ product
  
  _⁂_ : ∀ {A B C D} → (A ⇒ B) → (C ⇒ D) → ((A × C) ⇒ (B × D))
  f ⁂ g = [ product ⇒ product ] f ⁂ g

  -- TODO: this is probably harder to use than necessary because of this definition. Maybe make a version
  -- that doesn't have an explicit id in it, too?
  first : ∀ {A B C} → (A ⇒ B) → ((A × C) ⇒ (B × C))
  first f = f ⁂ id

  second : ∀ {A C D} → (C ⇒ D) → ((A × C) ⇒ (A × D))
  second g = id ⁂ g

  -- Just to make this more obvious
  .π₁∘⁂ : ∀ {A B C D} → {f : A ⇒ B} → {g : C ⇒ D} → π₁ ∘ (f ⁂ g) ≡ f ∘ π₁
  π₁∘⁂ {f = f} {g} = commute₁

  .π₂∘⁂ : ∀ {A B C D} → {f : A ⇒ B} → {g : C ⇒ D} → π₂ ∘ (f ⁂ g) ≡ g ∘ π₂
  π₂∘⁂ {f = f} {g} = commute₂

  .⁂∘⟨⟩ : ∀ {A B C D E} → {f : B ⇒ C} {f′ : A ⇒ B} {g : D ⇒ E} {g′ : A ⇒ D} → (f ⁂ g) ∘ ⟨ f′ , g′ ⟩ ≡ ⟨ f ∘ f′ , g ∘ g′ ⟩
  ⁂∘⟨⟩ {f = f} {f′} {g} {g′} = sym (universal helper₁ helper₂)
    where
    helper₁ : π₁ ∘ ((f ⁂ g) ∘ ⟨ f′ , g′ ⟩) ≡ f ∘ f′
    helper₁ = 
      begin
        π₁ ∘ ((f ⁂ g) ∘ ⟨ f′ , g′ ⟩)
      ↑⟨ assoc ⟩
        (π₁ ∘ (f ⁂ g)) ∘ ⟨ f′ , g′ ⟩
      ↓⟨ ∘-resp-≡ˡ π₁∘⁂ ⟩
        (f ∘ π₁) ∘ ⟨ f′ , g′ ⟩
      ↓⟨ assoc ⟩
        f ∘ (π₁ ∘ ⟨ f′ , g′ ⟩)
      ↓⟨ ∘-resp-≡ʳ commute₁ ⟩
        f ∘ f′
      ∎
      where
      open HomReasoning

    helper₂ : π₂ ∘ ((f ⁂ g) ∘ ⟨ f′ , g′ ⟩) ≡ g ∘ g′
    helper₂ = 
      begin
        π₂ ∘ ((f ⁂ g) ∘ ⟨ f′ , g′ ⟩)
      ↑⟨ assoc ⟩
        (π₂ ∘ (f ⁂ g)) ∘ ⟨ f′ , g′ ⟩
      ↓⟨ ∘-resp-≡ˡ π₂∘⁂ ⟩
        (g ∘ π₂) ∘ ⟨ f′ , g′ ⟩
      ↓⟨ assoc ⟩
        g ∘ (π₂ ∘ ⟨ f′ , g′ ⟩)
      ↓⟨ ∘-resp-≡ʳ commute₂ ⟩
        g ∘ g′
      ∎
      where
      open HomReasoning

  .first∘⟨⟩ : ∀ {A B C D} → {f : B ⇒ C} {f′ : A ⇒ B} {g′ : A ⇒ D} → first f ∘ ⟨ f′ , g′ ⟩ ≡ ⟨ f ∘ f′ , g′ ⟩
  first∘⟨⟩ {f = f} {f′} {g′} = 
    begin
      first f ∘ ⟨ f′ , g′ ⟩
    ↓⟨ ⁂∘⟨⟩ ⟩
      ⟨ f ∘ f′ , id ∘ g′ ⟩ 
    ↓⟨ ⟨⟩-cong₂ refl identityˡ ⟩
      ⟨ f ∘ f′ , g′ ⟩
    ∎
    where
    open HomReasoning

  .second∘⟨⟩ : ∀ {A B D E} → {f′ : A ⇒ B} {g : D ⇒ E} {g′ : A ⇒ D} → second g ∘ ⟨ f′ , g′ ⟩ ≡ ⟨ f′ , g ∘ g′ ⟩
  second∘⟨⟩ {f′ = f′} {g} {g′} = 
    begin
      second g ∘ ⟨ f′ , g′ ⟩
    ↓⟨ ⁂∘⟨⟩ ⟩
      ⟨ id ∘ f′ , g ∘ g′ ⟩ 
    ↓⟨ ⟨⟩-cong₂ identityˡ refl ⟩
      ⟨ f′ , g ∘ g′ ⟩
    ∎
    where
    open HomReasoning

  .⁂∘⁂ : ∀ {A B C D E F} → {f : B ⇒ C} → {f′ : A ⇒ B} {g : E ⇒ F} {g′ : D ⇒ E} → (f ⁂ g) ∘ (f′ ⁂ g′) ≡ (f ∘ f′) ⁂ (g ∘ g′)
  ⁂∘⁂ {B = B} {E = E} {f = f} {f′} {g} {g′} = 
    begin
      (f ⁂ g) ∘ (f′ ⁂ g′)
    ↓⟨ ⁂∘⟨⟩ ⟩
      ⟨ f ∘ (f′ ∘ π₁) , g ∘ (g′ ∘ π₂) ⟩
    ↑⟨ ⟨⟩-cong₂ assoc assoc ⟩
      (f ∘ f′) ⁂ (g ∘ g′)
    ∎
    where
    open HomReasoning

  .⟨⟩∘ : ∀ {A B C D} {f : A ⇒ B} {g : A ⇒ C} {q : D ⇒ A} → ⟨ f , g ⟩ ∘ q ≡ ⟨ f ∘ q , g ∘ q ⟩
  ⟨⟩∘ = sym (universal (trans (sym assoc) (∘-resp-≡ˡ commute₁)) (trans (sym assoc) (∘-resp-≡ˡ commute₂)))
  
  .first∘first : ∀ {A B C D}{f : B ⇒ C} {g : A ⇒ B}
    → first f ∘ first g ≡ first {C = D} (f ∘ g)
  first∘first {A}{B}{C}{D}{f}{g} =
    begin
        first f ∘ first g
    ↓⟨ first∘⟨⟩ ⟩
        ⟨ f ∘ g ∘ π₁ , id ∘ π₂ ⟩
    ↑⟨ ⟨⟩-cong₂ assoc refl ⟩
        first (f ∘ g)
    ∎
    where
    open HomReasoning
  
  .second∘second : ∀ {A B C D}{f : B ⇒ C} {g : A ⇒ B}
    → second f ∘ second g ≡ second {A = D} (f ∘ g)
  second∘second {A}{B}{C}{D}{f}{g} =
    begin
        second f ∘ second g
    ↓⟨ second∘⟨⟩ ⟩
        ⟨ id ∘ π₁ , f ∘ g ∘ π₂ ⟩
    ↑⟨ ⟨⟩-cong₂ refl assoc ⟩
        second (f ∘ g)
    ∎
    where
    open HomReasoning
  
  .first↔second : ∀ {A B C D}{f : A ⇒ B}{g : C ⇒ D}
    → first f ∘ second g ≡ second g ∘ first f
  first↔second {A}{B}{C}{D}{f}{g} =
    begin
      first f ∘ second g
    ↓⟨ ⁂∘⁂ ⟩
        (f ∘ id) ⁂ (id ∘ g)
    ↓⟨ ⁂-cong₂ product product identityʳ identityˡ ⟩
        f ⁂ g
    ↑⟨ ⁂-cong₂ product product identityˡ identityʳ ⟩
        (id ∘ f) ⁂ (g ∘ id)
    ↑⟨ ⁂∘⁂ ⟩
      second g ∘ first f
    ∎
    where
    open HomReasoning
