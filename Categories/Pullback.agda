{-# OPTIONS --universe-polymorphism #-}
open import Categories.Category

module Categories.Pullback {o a} (C : Category o a) where

open Category C

open import Level
open import Categories.Operations

record Pullback {X Y Z}(f : X ⇒ Z)(g : Y ⇒ Z) : Set (o ⊔ a) where
  field
    P  : Obj
    p₁ : P ⇒ X
    p₂ : P ⇒ Y

  field
    .commutes : f ∘ p₁ ≡ g ∘ p₂

    universal : ∀ {Q}(q₁ : Q ⇒ X)(q₂ : Q ⇒ Y)
              → (commutes : f ∘ q₁ ≡ g ∘ q₂) → (Q ⇒ P)

    .universal-unique : ∀ {Q} {q₁ : Q ⇒ X} {q₂ : Q ⇒ Y}
                        {commutes : f ∘ q₁ ≡ g ∘ q₂}
                          (u : Q ⇒ P)
                          (p₁∘u≡q₁ : p₁ ∘ u ≡ q₁)
                          (p₂∘u≡q₂ : p₂ ∘ u ≡ q₂)
                      →   u ≡ universal q₁ q₂ commutes

    .p₁∘universal≡q₁  : ∀ {Q} {q₁ : Q ⇒ X} {q₂ : Q ⇒ Y}
                          {commutes : f ∘ q₁ ≡ g ∘ q₂}
                      →   (p₁ ∘ universal q₁ q₂ commutes ≡ q₁)

    .p₂∘universal≡q₂  : ∀ {Q} {q₁ : Q ⇒ X} {q₂ : Q ⇒ Y}
                          {commutes : f ∘ q₁ ≡ g ∘ q₂}
                      →   (p₂ ∘ universal q₁ q₂ commutes ≡ q₂)


