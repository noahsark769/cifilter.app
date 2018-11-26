import React from 'react';
import styled from 'styled-components';
import Logo from './Logo';

const LogoWrapper = styled.div`
    display: inline-block;
    width: 30px;
    height: 30px;
`;

const StyledNav = styled.nav`
    width: 100%;
    display: flex;
    flex-direction: horizontal;
`;

const Title = styled.div`
    font-size: 24;
    font-weight: bold;
    font-family: 'Roboto', 'Open Sans', Helvetica, sans-serif;
    display: inline-block;
`;

const LogoAndTitle = styled.div`
    flex: 2;

    display: flex;
    flex-direction: horizontal;
    align-items: center;
`;

const Other = styled.div`
    flex: 10;

    display: flex;
    flex-direction: horizontal;
    justify-content: flex-end;
    align-items: center;
`;

const NavLink = styled.a`
    color: #F5BD5D;
    cursor: pointer;

    &:hover {
        text-decoration: underline;
    }
`;

const Nav = (props) => {
    return (
        <StyledNav className="padding--md">
            <LogoAndTitle>
                <LogoWrapper className="margin-right--sm">
                    <Logo />
                </LogoWrapper>
                <Title>CIFilter.io</Title>
            </LogoAndTitle>
            <Other>
                <NavLink className="margin-right--md">ABOUT</NavLink>
                <NavLink>SUPPORT</NavLink>
            </Other>
        </StyledNav>
    )
};
export default Nav;